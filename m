From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Sat, 21 Jun 2003 23:36:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030621.233634.67057417.yoshfuji@linux-ipv6.org>
References: <3EF37458.3070103@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <3EF37458.3070103@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Grr, I've almost lost this...


In article <3EF37458.3070103@us.ibm.com> (at Fri, 20 Jun 2003 13:53:44 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> 1. I change the netlink_dump_start to pass another parameter, <type>, which is
>     stored in a new field in the cb, <type>. All users of this function have been
>     changed to pass a -1 since they don't care about the type, except the
>     generic routine rtnetlink_rcv_msg() which calculates the type and stores it.
>     So the same routine which is used to dump route table can be used to dump
>     the prefix list by checking the type. It might be possible to derive the
>     type from the table offset, but that is more complicated (probably doable).

I think this is not required.

Rename inet6_dump_fib() to __inet6_dump_fib() and introduce
extra argument. and call it like
  inet6_dump_fib()    { __inet6_dump_fib(...,0); }
and
  inet6_dump_prefix() { __inet6_dump_fib(...,1); }
etc.


> 3. Added user interface for retrieving M/O flags. This is a separate interface
>     from the one for getting the prefix list since the flags are per interface
>     while the prefix list is per route. However these two can be merged into one
>     if needed.

Hmm, what I expected is to get information via RTA_NEWLINK message.
This is because, this is per-interface thing.


> 5. Though this patch is modified to use only routing table for updating and
>     accessing the prefix list, I did a performace analysis for this approach vs
>     storing the plist on the idev. Following is the result :
> 
>     System : 1 CPU. 866 MHz, 256MB memory
>     For 1000 VLAN devices (4036 route entries gets created automatically as part
>     of address assignment), retrieve prefix list for (system times only) :
> 
>     #devices  #iteration for each dev  plist on IDEV    plist in RTTABLE     %
>     200          100                   3.95 secs        40.14 secs          916%
>     1000         10                    2.60 secs        20.98 secs          706%
>     200          1000                  38.44 secs       400.76 secs         942%

Hmm...

Well, what should we do...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
