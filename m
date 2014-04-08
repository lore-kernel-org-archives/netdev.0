From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 21:04:33 +0200
Message-ID: <53444841.2010702@redhat.com>
References: <20140408.131819.1373401078750444800.davem@davemloft.net> <53442FD0.5020609@redhat.com> <20140408.141918.1353780924646899277.davem@redhat.com> <20140408.144601.1499418906739470715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org, tgraf@suug.ch,
	nhorman@tuxdriver.com, vyasevic@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757861AbaDHTFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 15:05:11 -0400
In-Reply-To: <20140408.144601.1499418906739470715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2014 08:46 PM, David Miller wrote:
>
> Daniel and Vlad, I'm about to send Linus a pull request.
>
> I know that you still need to fixup this SCTP change and it'll be
> in there, but I really need to get the changes in my tree staged
> so that I can do a set of -stable submissions.
>
> So please don't freak out, I know that this change still needs work
> and shouldn't go to -stable just yet :-)

Noted, thanks. I think the issue is that in sctp_association_free()
we do a list_del(&asoc->asocs) and then flush sctp_outq_free() which
will then access on sctp_wfree() a poisoned entry. I think this
should be list_del_init() instead.
