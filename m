From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2] bridge link: add option 'self'
Date: Thu, 4 Dec 2014 22:52:50 -0800
Message-ID: <CAE4R7bA3JSyHxe5ptVzpCzP5nHmKm8KyPqGvK7a_N2TWX-BNRw@mail.gmail.com>
References: <1417746436-41023-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:53047 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaLEGwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 01:52:51 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so108750wgh.4
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 22:52:50 -0800 (PST)
In-Reply-To: <1417746436-41023-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 6:27 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Currently self is set internally only if hwmode is set.
> This makes it necessary for the hw to have a mode.
> There is no hwmode really required to go to hardware. So, introduce
> self for anybody who wants to target hardware.

Can you include unwinding the hwmode 'swdev' setting for
kernel/iproute2 in v2?  With this "self" option, and your new
NETIF_F_HW_SWITCH_OFFLOAD flag, we don't need the hwmde 'swdev'.

> ---
>  bridge/link.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/bridge/link.c b/bridge/link.c
> index 90d9e7f..2b86141 100644
> --- a/bridge/link.c
> +++ b/bridge/link.c
> @@ -321,6 +321,9 @@ static int brlink_modify(int argc, char **argv)
>                                         "\"veb\".\n");
>                                 exit(-1);
>                         }
> +               } else if (strcmp(*argv, "self") == 0) {
> +                       NEXT_ARG();
> +                       flags = BRIDGE_FLAGS_SELF;
>                 } else {
>                         usage();
>                 }
> --
> 1.7.10.4
>
