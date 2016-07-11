From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v6 01/12] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 23:21:48 +0200
Message-ID: <57840DEC.2040008@iogearbox.net>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-2-git-send-email-bblanco@plumgrid.com> <CALx6S343W6nyV51fXqu4Mx5pLL9OZGv=WyMj6gxEHAUn80DQxQ@mail.gmail.com> <20160711165140.GB22729@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>
To: Brenden Blanco <bblanco@plumgrid.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39316 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932240AbcGKVVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:21:55 -0400
In-Reply-To: <20160711165140.GB22729@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2016 06:51 PM, Brenden Blanco wrote:
> On Sun, Jul 10, 2016 at 03:56:02PM -0500, Tom Herbert wrote:
>> On Thu, Jul 7, 2016 at 9:15 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
[...]
>>> +static bool __is_valid_xdp_access(int off, int size,
>>> +                                 enum bpf_access_type type)
>>> +{
>>> +       if (off < 0 || off >= sizeof(struct xdp_md))
>>> +               return false;
>>> +       if (off % size != 0)
>>
>> off & 3 != 0
> Feasible, but was intending to keep with the surrounding style. What do
> the other bpf maintainers think?
>>
>>> +               return false;
>>> +       if (size != 4)
>>> +               return false;
>>
>> If size must always be 4 why is it even an argument?
> Because this is the first time that the verifier has a chance to check
> it, and size == 4 could potentially be a prog_type-specific requirement.

Yep and wrt above, I think it's more important that all is_valid_*_access()
functions are consistent to each other and easily reviewable than adding
optimizations to some of them, which is slow-path anyway. If we find a nice
simplification, then we should apply it also to others obviously.
