From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: xen-netback notify DomU to send ARP.
Date: Tue, 08 Jan 2013 23:40:45 +0800
Message-ID: <50EC3DFD.8060206@oracle.com>
References: <50EC099D.6020407@oracle.com>
	<50EC297A02000078000B3BB5@nat28.tlf.novell.com>
	<1357652541.7989.179.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1638402373440488599=="
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1357652541.7989.179.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============1638402373440488599==
Content-Type: multipart/alternative;
 boundary="------------010802030200030302040207"

This is a multi-part message in MIME format.
--------------010802030200030302040207
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


On 2013-1-8 21:42, Ian Campbell wrote:
> On Tue, 2013-01-08 at 13:13 +0000, Jan Beulich wrote:
>>>>> On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com> wrote:
>>>     When Xen Dom0's network circumstance changed, DomU
>>> should be notified in some special condition. For
>>> example the below circumstance:
>>>     ping from Guest A to DomU:
>>>     Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
>>>                 eth1 /
>>>     when eth0 inactive, and eth1 active.
> How is eth0 failing? Are you unplugging it, un-enslaving it or taking
> some other sort of administrative action?
In my emulation environment, i unplug it or ifdown the interface, while 
eth0 maybe wrong in productive environment.
>
> Which bonding mode are you using?
Bond running in active-backup mode.
>
> Doesn't this state change cause the switch to which eth0 and eth1 are
> attached to forget the MAC tables associated with the eth0 port, meaning
> that subsequent traffic will be flooded until it learns that eth1 is the
> new port?
>
>>>     Guest A --> eth0   bond0 - xenbr0 --VIF(DOMU)
>>>                 eth1 /
>>>     Guest A will don't reach to DomU. After Guest A
>>>     send ARP request and DomU respond, Guest A will
>>>     reach DomU. But some more second will be elapsed.
>>>                 eth0   bond0 - xenbr0 --VIF(DOMU)
>>>     Guest A --> eth1/
>> Isn't a change to the availability of the bonds supposed to be
>> transparent to Guest A _and_ DomU? I.e. aren't you trying to fix
>> an eventual problem here in the wrong place?
> In non-virtualised bonding the bonding drive can take care of some of
> this because it knows its own MAC address and can send appropriate
> gratuitous frames (depends on the bonding mode) to paper over things. In
> the virtualised case it (most likely) doesn't know VIF(DOMU)s MAC
> address.
   If you have know all ip and mac before modprobe bond, you can 
configure the bond argument. But you don't know all ip and mac before 
start new virtual.
   If bond want to know all DomU's ip and mac which pass through, it 
must check all skb. it's not good idea.
>
>>> If Xen netback watch the network change, will notify
>>> DomU by change it own status. So netfront will watch
>>> netback's change, and DomU send ARP initiative.
>> Your patch is, at least according to what I see, completely
>> unusable - line breaks dropped, line order reversed, and
>> (guessing) some UTF-16/UCS-2 characters inserted at the top.
>> Please attach patches as plain ASCII.
>  From the name it looks to me like it is the vi temp file created while
> you have the file open rather than the actual patch file...
>
> Ian.
>
Thanks,
Jason


--------------010802030200030302040207
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-text-flowed" style="font-family: -moz-fixed;
      font-size: 13px;" lang="x-unicode">
      <br>
      On 2013-1-8 21:42, Ian Campbell wrote:
      <br>
      <blockquote type="cite" style="color: #000000;">On Tue, 2013-01-08
        at 13:13 +0000, Jan Beulich wrote:
        <br>
        <blockquote type="cite" style="color: #000000;">
          <blockquote type="cite" style="color: #000000;">
            <blockquote type="cite" style="color: #000000;">
              <blockquote type="cite" style="color: #000000;">On
                08.01.13 at 12:57, jianhai luan <a
                  class="moz-txt-link-rfc2396E"
                  href="mailto:jianhai.luan@oracle.com">&lt;jianhai.luan@oracle.com&gt;</a>
                wrote:
                <br>
              </blockquote>
            </blockquote>
                When Xen Dom0's network circumstance changed, DomU
            <br>
            should be notified in some special condition. For
            <br>
            example the below circumstance:
            <br>
                ping from Guest A to DomU:
            <br>
                Guest A --&gt; eth0 - bond0 - xenbr0 --VIF(DOMU)
            <br>
                            eth1 /
            <br>
                when eth0 inactive, and eth1 active.
            <br>
          </blockquote>
        </blockquote>
        How is eth0 failing? Are you unplugging it, un-enslaving it or
        taking
        <br>
        some other sort of administrative action?
        <br>
      </blockquote>
      In my emulation environment, i unplug it or ifdown the interface,
      while eth0 maybe wrong in productive environment.
      <br>
      <blockquote type="cite" style="color: #000000;">
        <br>
        Which bonding mode are you using?
        <br>
      </blockquote>
      Bond running in active-backup mode.
      <br>
      <blockquote type="cite" style="color: #000000;">
        <br>
        Doesn't this state change cause the switch to which eth0 and
        eth1 are
        <br>
        attached to forget the MAC tables associated with the eth0 port,
        meaning
        <br>
        that subsequent traffic will be flooded until it learns that
        eth1 is the
        <br>
        new port?
        <br>
        <br>
        <blockquote type="cite" style="color: #000000;">
          <blockquote type="cite" style="color: #000000;">    Guest A
            --&gt; eth0   bond0 - xenbr0 --VIF(DOMU)
            <br>
                            eth1 /
            <br>
                Guest A will don't reach to DomU. After Guest A
            <br>
                send ARP request and DomU respond, Guest A will
            <br>
                reach DomU. But some more second will be elapsed.
            <br>
                            eth0   bond0 - xenbr0 --VIF(DOMU)
            <br>
                Guest A --&gt; eth1/
            <br>
          </blockquote>
          Isn't a change to the availability of the bonds supposed to be
          <br>
          transparent to Guest A <span class="moz-txt-underscore"><span
              class="moz-txt-tag">_</span>and<span class="moz-txt-tag">_</span></span>
          DomU? I.e. aren't you trying to fix
          <br>
          an eventual problem here in the wrong place?
          <br>
        </blockquote>
        In non-virtualised bonding the bonding drive can take care of
        some of
        <br>
        this because it knows its own MAC address and can send
        appropriate
        <br>
        gratuitous frames (depends on the bonding mode) to paper over
        things. In
        <br>
        the virtualised case it (most likely) doesn't know VIF(DOMU)s
        MAC
        <br>
        address.
        <br>
      </blockquote>
        If you have know all ip and mac before modprobe bond, you can
      configure the bond argument. But you don't know all ip and mac
      before start new virtual.
      <br>
        If bond want to know all DomU's ip and mac which pass through,
      it must check all skb. it's not good idea.
      <br>
      <blockquote type="cite" style="color: #000000;">
        <br>
        <blockquote type="cite" style="color: #000000;">
          <blockquote type="cite" style="color: #000000;">If Xen netback
            watch the network change, will notify
            <br>
            DomU by change it own status. So netfront will watch
            <br>
            netback's change, and DomU send ARP initiative.
            <br>
          </blockquote>
          Your patch is, at least according to what I see, completely
          <br>
          unusable - line breaks dropped, line order reversed, and
          <br>
          (guessing) some UTF-16/UCS-2 characters inserted at the top.
          <br>
          Please attach patches as plain ASCII.
          <br>
        </blockquote>
         From the name it looks to me like it is the vi temp file
        created while
        <br>
        you have the file open rather than the actual patch file...
        <br>
        <br>
        Ian.
        <br>
        <br>
      </blockquote>
      Thanks,<br>
      Jason<br>
      <br>
    </div>
  </body>
</html>

--------------010802030200030302040207--


--===============1638402373440488599==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============1638402373440488599==--
