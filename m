From: Russell Stuart <russell-lartc@stuart.id.au>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Tue, 14 Mar 2006 12:29:38 +1000
Message-ID: <1142303378.17608.142.camel@ras.pc.brisbane.lube>
References: <1139538806.15476.33.camel@ras> <1142082696.5184.53.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1142082696.5184.53.camel@jzny2>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Sat, 2006-03-11 at 08:11 -0500, jamal wrote:
> On Fri, 2006-10-02 at 12:33 +1000, Russell Stuart wrote:
> > This patch adds a "divisor" option to tc's "sample"
> > clause: 
> 
> While this looks right - can we have more test data with tc filter ls
> both before and after your fix? Specify divisor of 256 and 16 for
> example. Show that for the 256 it is the same as before and for 16 it
> does the right thing.

With patch, divisor 256:
  tc qdisc del dev eth0 root
  tc qdisc add dev eth0 root handle 1: htb
  tc filter add dev eth0 parent 1:0 prio 1 protocol ip u32 ht 801: divisor 256
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x01 0xff divisor 256 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x0f 0xff divisor 256 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x10 0xff divisor 256 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0xef 0xff divisor 256 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0xf0 0xff divisor 256 match u32 0 0
  tc -s filter show dev eth0
    filter parent 1: protocol ip pref 1 u32
    filter parent 1: protocol ip pref 1 u32 fh 801: ht divisor 256
    filter parent 1: protocol ip pref 1 u32 fh 801:1:800 order 2048 key ht 801 bkt 1 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:f:800 order 2048 key ht 801 bkt f flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:10:800 order 2048 key ht 801 bkt 10 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:ef:800 order 2048 key ht 801 bkt ef flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:f0:800 order 2048 key ht 801 bkt f0 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1

Without patch, divisor 256:
  tc qdisc add dev eth0 root handle 1: htb
  tc filter add dev eth0 parent 1:0 prio 1 protocol ip u32 ht 801: divisor 256
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x01 0xff match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x0f 0xff match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x10 0xff match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0xef 0xff match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0xf0 0xff match u32 0 0
  tc -s filter show dev eth0
    filter parent 1: protocol ip pref 1 u32
    filter parent 1: protocol ip pref 1 u32 fh 801: ht divisor 256
    filter parent 1: protocol ip pref 1 u32 fh 801:1:800 order 2048 key ht 801 bkt 1 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:f:800 order 2048 key ht 801 bkt f flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:10:800 order 2048 key ht 801 bkt 10 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:ef:800 order 2048 key ht 801 bkt ef flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:f0:800 order 2048 key ht 801 bkt f0 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1

With patch, divisor 16:
  tc qdisc del dev eth0 root
  tc qdisc add dev eth0 root handle 1: htb
  tc filter add dev eth0 parent 1:0 prio 1 protocol ip u32 ht 801: divisor 16
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x01 0xff divisor 16 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x0f 0xff divisor 16 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0x10 0xff divisor 16 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0xef 0xff divisor 16 match u32 0 0
  tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 ht 801: classid 1:0 sample u8 0xf0 0xff divisor 16 match u32 0 0
  tc -s filter show dev eth0
    filter parent 1: protocol ip pref 1 u32
    filter parent 1: protocol ip pref 1 u32 fh 801: ht divisor 16
    filter parent 1: protocol ip pref 1 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801::801 order 2049 key ht 801 bkt 0 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:1:800 order 2048 key ht 801 bkt 1 flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:f:800 order 2048 key ht 801 bkt f flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 801:f:801 order 2049 key ht 801 bkt f flowid 1:
      match 00000000/00000000 at 0
    filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
