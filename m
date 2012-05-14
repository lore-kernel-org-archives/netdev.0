From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 17:05:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1205141702110.11548@frira.vanv.qr>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com> <20120514144052.GD12992@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, dan.carpenter@oracle.com,
	hans@schillstrom.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120514144052.GD12992@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2012-05-14 16:40, Pablo Neira Ayuso wrote:

>> -		if (t->uports.p16.dst < t->uports.p16.src)
>> +		if (ntohs(t->uports.p16.dst) < ntohs(t->uports.p16.src))
>
>Do we really need this to make sparse happy?

You need it to make *maths* happy.

Consider

	384 < 65407

but

	    ntohs(384) > ntohs(65407)
	<=> 32769 > 32767
