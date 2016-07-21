From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: WAS ( Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Thu, 21 Jul 2016 16:42:40 +0200
Message-ID: <5790DF60.5010900@iogearbox.net>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com> <20160718041933.GB36253@ast-mbp.thefacebook.com> <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net> <578CAA96.2090501@mojatatu.com> <578E2960.7080709@iogearbox.net> <578E3172.9020601@mojatatu.com> <578E414C.1080501@iogearbox.net> <CAM_iQpWX5HT_yF3guCbQLMo2GSVGA8BTcJ3_bucHrnBrMQbjqw@mail.gmail.com> <578EC467.2010808@iogearbox.net> <742d87f4-b1af-ff02-93a9-bdcd369492af@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53505 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbcGUOmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 10:42:45 -0400
In-Reply-To: <742d87f4-b1af-ff02-93a9-bdcd369492af@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2016 09:27 AM, Jamal Hadi Salim wrote:
[...]
> Forgot about csum which would work with pedit - didnt quiet parse what
> you are saying above though:
> does changing MAC address require changing to CHECKSUM_NONE? If yes,
> then seems like i need to send a patch for act_ife as well to make in
> the spirit of mirred?

Hmm, seems fine actually up to ETH_HLEN. In cases like vlan or mpls
modifications there's certainly a correction, but when going into rx
path this is pulled out already of the calculation afaik (see f.e.
dev_forward_skb()). So when mirred pushes this back in via skb_push_rcsum()
and dev_forward_skb() back out, it should be okay if I see this correctly.
But don't you still something like need skb_try_make_writable()?
