From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 15:27:57 +0200
Message-ID: <55252CDD.8020503@iogearbox.net>
References: <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com> <5524B339.1070403@plumgrid.com> <5524E878.7070803@iogearbox.net> <20150408090520.GA2057@nanopsycho.orion> <552508E8.5050203@iogearbox.net> <55250D92.6030702@iogearbox.net> <55251556.4040900@mojatatu.com> <55251F9F.2050508@iogearbox.net> <55252611.3040109@mojatatu.com> <20150408131417.GA28656@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37895 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbbDHN2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:28:09 -0400
In-Reply-To: <20150408131417.GA28656@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 03:14 PM, Thomas Graf wrote:
> On 04/08/15 at 08:58am, Jamal Hadi Salim wrote:
>> On 04/08/15 08:31, Daniel Borkmann wrote:
>>> That means the tc's cls_u32
>>> sample selectors a la ip, ip6, udp, tcp, icmp don't work on ingress
>>> either,so in u32 speak you would need to do that by hand, but that
>>> doesn't work as you don't have the Ethernet type context available.
>>> Am I missing something? :)
>>
>> u32 works fine. I am sure i have tests which run these on both
>> in/egress.
>
> His point is that an u32 filter written for egress won't work at
> ingress because the offsets are different. This has always been the
> case and we can't break this behaviour either. I'm sure you have
> these weird negative offset u32 egress filters in your repertoire
> as well ;-)

Okay, you can use negative offsets in cls_u32 to accomodate for
that; so yeah, you'd need to implement your filter differently
on ingress. That should also work on cls_bpf et al.
