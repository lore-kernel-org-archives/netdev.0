From: "Shigeo N" <shigeonx@gmail.com>
Subject: Re: XTP for 2.6.25
Date: Fri, 25 Apr 2008 16:59:45 +0900
Message-ID: <18b669d80804250059m793f3f56xc4fdb8bad949fa3@mail.gmail.com>
References: <18b669d80804240314t7b2f6e4cpc9a9f2690c6d21b4@mail.gmail.com>
	 <873apbijb9.fsf@basil.nowhere.org>
	 <18b669d80804240606n47854939x94278f8d974034c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:5607 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbYDYH7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:59:47 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3494849fgb.17
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 00:59:45 -0700 (PDT)
In-Reply-To: <18b669d80804240606n47854939x94278f8d974034c1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I emulated WAN delay by netem and compared the performance again.

case1) fixed delay

    <------------- 100Mbps -------------->
Host1 --------- Linux Router ---------- Host2

 In this case, just adds a fixed amount of delay to all packets going
out on Linux Router by command, "tc qdisc add dev eth0 root netem
delay 100ms".

 Here is the result.

    fixed delay    UDP/TCP/XTP throghput
  ---------------------------------------
      10ms         88/85/92 Mbps
      30ms         88/70/91 Mbps
      50ms         88/63/89 Mbps
      70ms         88/52/84 Mbps
     100ms         88/36/70 Mbps


case2) random delay

 In this case, add a fixed amount of delay + 10% random delay by
command, "tc change dev eth0 root netem delay 100ms 10ms 25%".

 Here is the result.

    fixed delay    UDP/TCP/XTP throghput
  ---------------------------------------
      10ms         88/80/92 Mbps
      30ms         88/51/91 Mbps
      50ms         88/41/89 Mbps
      70ms         88/28/80 Mbps
     100ms         88/19/66 Mbps

 TCP's perfomance looks very poor when delay is long and variable.

Thanks
Shigeo


On Thu, Apr 24, 2008 at 10:06 PM, Shigeo N <shigeonx@gmail.com> wrote:
> Now I have connected 2 hosts directly, and evaluate the each throughput.
>  Then all the results of UDP, TCP and XTP are the same and 94Mbps. (My
>  netwrok is 100Base/TX).
>
>  In this case round-trip time between 2 hosts is less than 0.1ms
>  because they are directly connected. But my previouse case, round-trip
>  time between 2 hosts are 4ms. (I use IPSEC between the security
>  gateways to increase delay).
>  I think that's the reason TCP throughput is slow. If ACK packets are
>  delayed, sending window cannot slide and sending packets cannot be
>  fully bursted.
>
>  If I changes wmem size through /proc/sys/net/ipv4/tcp_wmem, TCP's
>  throughput may improve, but congestion control becomes more difficult
>  for TCP.
>
>  That is TCP's disadvantage to XTP.
>
>  Best
>  Shigeo
>
>
>
>  On 4/24/08, Andi Kleen <andi@firstfloor.org> wrote:
>  > "Shigeo N" <shigeonx@gmail.com> writes:
>  > >
>  > > I tested in the network where UDP throughput is 29Mbps, then TCP
>  > > throughput was 13Mbps, but XTP's reached to 25Mbps.
>  >
>  > One interesting question is why TCP was so much slower than UDP
>  > on your test. It shouldn't be on a fair test setup.
>  >
>  > Please post details. Was the network losing packets?
>  >
>  > New protocols might be interesting, but even more interesting is to
>  > fix any (real) problems in existing protocols.
>  >
>  > -Andi
>  >
>
