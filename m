From: Jason Luan <luanjianhai@163.com>
Subject: Re: xen-netback notify DomU to send ARP.
Date: Wed, 09 Jan 2013 23:07:55 +0800
Message-ID: <50ED87CB.3090109@163.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5563016224653510513=="
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com, JBeulich@suse.com,
	konrad.wilk@oracle.com
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
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
--===============5563016224653510513==
Content-Type: multipart/alternative;
 boundary="------------020707000407050103050607"

This is a multi-part message in MIME format.
--------------020707000407050103050607
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit

于 2013年01月09日 20:03, Ian Campbell 写道:
> On Wed, 2013-01-09 at 01:07 +0000, Jason Luan wrote:
>> 于 2013年01月09日 00:00, Ian Campbell 写道:
>>> On Tue, 2013-01-08 at 15:40 +0000, jianhai luan wrote:
>>>> On 2013-1-8 21:42, Ian Campbell wrote:
>>>>> On Tue, 2013-01-08 at 13:13 +0000, Jan Beulich wrote:
>>>>>>>>> On 08.01.13 at 12:57, jianhai luan <jianhai.luan@oracle.com>
>>>>>>>>> wrote:
>>>>>>> When Xen Dom0's network circumstance changed, DomU
>>>>>>> should be notified in some special condition. For
>>>>>>> example the below circumstance:
>>>>>>> ping from Guest A to DomU:
>>>>>>> Guest A --> eth0 - bond0 - xenbr0 --VIF(DOMU)
>>>>>>> eth1 /
>>>>>>> when eth0 inactive, and eth1 active.
>>>>> How is eth0 failing? Are you unplugging it, un-enslaving it or
>>>>> taking
>>>>> some other sort of administrative action?
>>>> In my emulation environment, i unplug it or ifdown the interface,
>>> I expect these would behave rather different, since the affect of
>>> ifdown
>>> looks rather different to an unplug from the PoV of the switch.
>>>
>>> Is the ifdown case something which you are trying to solve or just what
>>> appeared to be a convenient test case? I'd be less inclined to worry
>>> about explict admin actions such as that.
>>>
>>> Unplugging the cable should cause:
>>>
>> I do above listed thing to let switch active slave only.
>> I think that we should put attention on the thing which bond switch
>> active slave interface in active-backup mode. In network circumstance,
>> many thing will cause the switch, what do Vif when the event happen?
> Sorry, I'm having a bit of trouble parsing the above, but are you asking
> what the VIF should do when the active slave in the bond changes without
> the previously active slave actually failing?
sorry for your misunderstanding.
>
> The issue is that traffic will continue to arrive on the now inactive
> slave, but will be discarded (the expected behaviour for
> Active/Passive)?
Yes. the traffic will continue to arrive on the switcher's port which
connected the inactive
slave before, and the switcher's port don't connect (or don't reach) the
inactive slave now,
so the link will be disconnected before DomU send ARP. After DomU send
ARP, the traffic will
know how to reach the correct switcher's port which connected with the
active slave.
>
> Is this something which happens in practice? Does the active slave
> change even while it remains a viable path?
Yes, please think the below the scene.
PC -- switcher
port A -- eth0 --bond0 --xenbr0 -DomU
port B -- eth1/
or
PC -- switcher A -- eth0 -- bond0 -- xenbr0 -- DomU
\- switcher B -- eth1 /

If Port A or switcher A wrong, the traffic from PC to DomU will be
disconnected before found
correct path (port B or Switcher B ).
>
> Ian.
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel


--------------020707000407050103050607
Content-Type: text/html; charset=GB2312
Content-Transfer-Encoding: 8bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=GB2312">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-text-flowed" style="font-family: -moz-fixed;
      font-size: 12px;" lang="x-unicode">于 2013年01月09日 20:03, Ian
      Campbell 写道:
      <br>
      <blockquote type="cite" style="color: #000000;">On Wed, 2013-01-09
        at 01:07 +0000, Jason Luan wrote:
        <br>
        <blockquote type="cite" style="color: #000000;">于 2013年01月09日
          00:00, Ian Campbell 写道:
          <br>
          <blockquote type="cite" style="color: #000000;">On Tue,
            2013-01-08 at 15:40 +0000, jianhai luan wrote:
            <br>
            <blockquote type="cite" style="color: #000000;">On 2013-1-8
              21:42, Ian Campbell wrote:
              <br>
              <blockquote type="cite" style="color: #000000;">On Tue,
                2013-01-08 at 13:13 +0000, Jan Beulich wrote:
                <br>
                <blockquote type="cite" style="color: #000000;">
                  <blockquote type="cite" style="color: #000000;">
                    <blockquote type="cite" style="color: #000000;">
                      <blockquote type="cite" style="color: #000000;">On
                        08.01.13 at 12:57, jianhai luan <a
                          class="moz-txt-link-rfc2396E"
                          href="mailto:jianhai.luan@oracle.com">&lt;jianhai.luan@oracle.com&gt;</a>
                        <br>
                        wrote:
                        <br>
                      </blockquote>
                    </blockquote>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; When Xen Dom0's network circumstance changed,
                    DomU
                    <br>
                    should be notified in some special condition. For
                    <br>
                    example the below circumstance:
                    <br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ping from Guest A to DomU:
                    <br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Guest A --&gt; eth0 - bond0 - xenbr0
                    --VIF(DOMU)
                    <br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; eth1 /
                    <br>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; when eth0 inactive, and eth1 active.
                    <br>
                  </blockquote>
                </blockquote>
                How is eth0 failing? Are you unplugging it, un-enslaving
                it or
                <br>
                taking
                <br>
                some other sort of administrative action?
                <br>
              </blockquote>
              In my emulation environment, i unplug it or ifdown the
              interface,
              <br>
            </blockquote>
            I expect these would behave rather different, since the
            affect of ifdown
            <br>
            looks rather different to an unplug from the PoV of the
            switch.
            <br>
            <br>
            Is the ifdown case something which you are trying to solve
            or just what
            <br>
            appeared to be a convenient test case? I'd be less inclined
            to worry
            <br>
            about explict admin actions such as that.
            <br>
            <br>
            Unplugging the cable should cause:
            <br>
            <br>
          </blockquote>
          I do above listed thing to let switch active slave only.
          <br>
          I think that we should put attention on the thing which bond
          switch
          <br>
          active slave interface in active-backup mode. In network
          circumstance,
          <br>
          many thing will cause the switch, what do Vif when the event
          happen?
          <br>
        </blockquote>
        Sorry, I'm having a bit of trouble parsing the above, but are
        you asking
        <br>
        what the VIF should do when the active slave in the bond changes
        without
        <br>
        the previously active slave actually failing?
        <br>
      </blockquote>
      sorry for your misunderstanding.
      <br>
      <blockquote type="cite" style="color: #000000;">
        <br>
        The issue is that traffic will continue to arrive on the now
        inactive
        <br>
        slave, but will be discarded (the expected behaviour for
        <br>
        Active/Passive)?
        <br>
      </blockquote>
      Yes. the traffic will continue to arrive on the switcher's port
      which connected the inactive
      <br>
      slave before, and the switcher's port don't connect (or don't
      reach) the inactive slave now,
      <br>
      so the link will be disconnected before DomU send ARP. After DomU
      send ARP, the traffic will
      <br>
      know how to reach the correct switcher's port which connected with
      the active slave.
      <br>
      <blockquote type="cite" style="color: #000000;">
        <br>
        Is this something which happens in practice? Does the active
        slave
        <br>
        change even while it remains a viable path?
        <br>
      </blockquote>
      Yes, please think the below the scene.
      <br>
      &nbsp; PC -- switcher
      <br>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; port A -- eth0 --bond0 --xenbr0 -DomU
      <br>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; port B -- eth1/
      <br>
      or
      <br>
      &nbsp; PC -- switcher A -- eth0 -- bond0 -- xenbr0 -- DomU
      <br>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; \- switcher B -- eth1 /
      <br>
      <br>
      If Port A or switcher A wrong,&nbsp; the traffic from PC to DomU will
      be disconnected before found
      <br>
      correct path (port B or Switcher B ).
      <br>
      <blockquote type="cite" style="color: #000000;">
        <br>
        Ian.
        <br>
        <br>
        <br>
        _______________________________________________
        <br>
        Xen-devel mailing list
        <br>
        <a class="moz-txt-link-abbreviated"
          href="mailto:Xen-devel@lists.xen.org">Xen-devel@lists.xen.org</a>
        <br>
        <a class="moz-txt-link-freetext"
          href="http://lists.xen.org/xen-devel">http://lists.xen.org/xen-devel</a>
        <br>
      </blockquote>
      <br>
    </div>
  </body>
</html>

--------------020707000407050103050607--



--===============5563016224653510513==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============5563016224653510513==--
