From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 93901] New: TCP Fast Open uses
Date: Thu, 26 Feb 2015 11:10:24 -0800
Message-ID: <1424977824.5565.175.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150226080729.4c567be9@urahara>
	 <1424967203.5565.164.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54EF5EE0.7040404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	rueth@comsys.rwth-aachen.de
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:33120 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbbBZTK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:10:26 -0500
Received: by iecar1 with SMTP id ar1so19679082iec.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 11:10:26 -0800 (PST)
In-Reply-To: <54EF5EE0.7040404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 09:58 -0800, Rick Jones wrote:
> On 02/26/2015 08:13 AM, Eric Dumazet wrote:
> > This is work in progress at Google, of course.
> >
> > Classic chicken and egg problem ;)
> 
> Does it need to be any more complicated than a sysctl which enables 
> accepting an alternate (the experimental) option value in addition to 
> the assigned, to be enabled (perhaps by default for a release or three) 
> for the server side, and then just switching the active connection 
> establishment side to the assigned number?
> 
> If the server is "old" and using the experimental version, the only 
> thing that will happen is the clients using the standardized version 
> will end-up falling back on the classic three-way handshake.  That 
> doesn't seem so bad.  Particularly since that option value was 
> "experimental" after all and presumably then not really meant for 
> "production" purposes :)

Really, if you are eager to see this coming, you could send a patch.

Or simply wait for the work being done by a Googler ;)

<quote Google-Bug-Id: 19264158 >

Add support to use RFC7413 option (34) for TCP Fast open while
supporting the old/current experimental option format. The idea is
a new client will request fast open cookie using option 34 
if the SYN-ACK contains TFO cookie with option 34. everything works out.
otherwise, the client retries the cookie request with the exp option in
the subsequent TFO connection attempt. if the server grants the cookie,
records the destination is an old server for the next (30?) days.
a new  server will respond TFO cookie based on the option number used in
cookie request.

</quote>
