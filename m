From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next v3 1/3] udp: Expand UDP tunnel common APIs
Date: Tue, 26 Aug 2014 22:17:18 -0700
Message-ID: <CACzMAJJ2uOeZEjq6bRvfXhbTNqipEPZ+1yFG48H1phwQn9_ruw@mail.gmail.com>
References: <1409110530-4383-1-git-send-email-azhou@nicira.com>
	<CA+mtBx-XKH7wYq4hsGLTn63i06JefQjaR3TfnhH2PyB2DM0R=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:56530 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751123AbaH0FRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 01:17:19 -0400
Received: by mail-ob0-f177.google.com with SMTP id wp18so11998705obc.8
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 22:17:18 -0700 (PDT)
In-Reply-To: <CA+mtBx-XKH7wYq4hsGLTn63i06JefQjaR3TfnhH2PyB2DM0R=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2014 at 9:12 PM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Aug 26, 2014 at 8:35 PM, Andy Zhou <azhou@nicira.com> wrote:
>> Added create_udp_tunnel_socket(), packet receive and transmit,  and
>> other related common functions for UDP tunnels.
>>
>> Per net open UDP tunnel ports are tracked in this common layer to
>> prevent sharing of a single port with more than one UDP tunnel.
>>
> This is not needed! If a UDP port is already bound (whether by another
> tunnel or not), then bind during tunnel initialization will fail. All
> this logic to store tunnel sockets in a separate list seems like
> unnecessary complexity. If a driver needs to track multiple ports it
> opens, it can do that on its own like VXLAN is already doing.

I was hoping to retain the udp_tunnel_find_sock() function which seems
to be common.
But it is not doing much at the moment, so I can just drop it in the
next version.
