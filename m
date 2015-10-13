From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Tue, 13 Oct 2015 11:28:13 +0200
Message-ID: <561CCEAD.206@iogearbox.net>
References: <1444318627-27883-1-git-send-email-edumazet@google.com> <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com> <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com> <56180147.6070205@iogearbox.net> <20151013092223.GE11304@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36201 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbbJMJ2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 05:28:18 -0400
In-Reply-To: <20151013092223.GE11304@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2015 11:22 AM, Tobias Klauser wrote:
> On 2015-10-09 at 20:02:47 +0200, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 10/09/2015 12:50 PM, Eric Dumazet wrote:
>>> On Thu, 2015-10-08 at 20:42 -0700, Tom Herbert wrote:
>>>> On Thu, Oct 8, 2015 at 8:37 AM, Eric Dumazet <edumazet@google.com> wrote:
>>>>> As promised in last patch series, we implement a better SO_REUSEPORT
>>>>> strategy, based on cpu affinities if selected by the application.
>>>>>
>>>>> We also moved sk_refcnt out of the cache line containing the lookup
>>>>> keys, as it was considerably slowing down smp operations because
>>>>> of false sharing. This was simpler than converting listen sockets
>>>>> to conventional RCU (to avoid sk_refcnt dirtying)
>>>>>
>>>>> Could process 6.0 Mpps SYN instead of 4.2 Mpps on my test server.
>>>>>
>>>> Is this IPv4, IPv6, or some combination of the two ? :-)
>>>
>>> IPv4 only (mostly because I was using trafgen and its csumtcp() only
>>> deals with IPv4 and I am lazy)
>>
>> Agreed, will fix that in trafgen. ;) Thanks!
>
> Daniel, I'd have som preliminary patches for trafgen ready to introduce
> the csumudp6 and csumtcp6 trafgen helper functions (UDP/TCP checksum
> using IPv6 pseudo headers). If you want I can push them after some
> further testing later today.

Was off yesterday, so looks like you beat me to it. So, yes, perfect,
please do! :)

> Eric, would these to helpers be sufficient for your use case or do you
> need any additional trafgen functionality?
