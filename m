From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 2/3] adds ieee80211_regdomains support
Date: Wed, 25 Oct 2006 11:16:42 -0400
Message-ID: <43e72e890610250816p4305d79epe3acf7fe3ff680d4@mail.gmail.com>
References: <43e72e890610231547k3cf6c590r4abd0a6fe7965fda@mail.gmail.com>
	 <ehmgs7$cba$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:30056 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030471AbWJYPQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 11:16:44 -0400
Received: by ug-out-1314.google.com with SMTP id 32so122318ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 08:16:42 -0700 (PDT)
To: "Anand Kumria" <wildfire@progsoc.org>
In-Reply-To: <ehmgs7$cba$1@sea.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Anand Kumria <wildfire@progsoc.org> wrote:
> On Mon, 23 Oct 2006 18:47:25 -0400, Luis R. Rodriguez wrote:
>
> > ieee80211_regdomains
> >
> > Breaks down regulatory domains into data structures which allow
> > drivers to share channel and power contraints based on stack
> > regulatory domain. This driver adds in-kernel support for common
> > regulatory domains (such as FCC and ETSI), makes updating the
>
> [snip]
>
> +/* Stack regulatory domain values. Atheros seems to have started this
> + * convention and most  hardware vendors followed their example.
> + * Although these are *very* common we allow for a hw-specific
> + * map between stack and device regdomain values. */
> +enum stack_regdomain {
> +       REGDOMAIN_WORLD         = 0x00, /* World compliance, minimum set */
> +       REGDOMAIN_FCC           = 0x10, /* USA */
> +       REGDOMAIN_IC            = 0x20, /* Canada */
> +       REGDOMAIN_ETSI          = 0x30, /* Europe */
> +       REGDOMAIN_SPAIN         = 0x31, /* Spain */
> +       REGDOMAIN_FRANCE        = 0x32, /* France */
> +       REGDOMAIN_MKK           = 0x40, /* Japan */
> +};
> +
>
> Why not pick either the country name or the organisation within the country
> that determines the frequency guidelines?

Ultimately I think this is the way this should work and this is why I
provide a alpha3 country code --> stack regulatory domain map.
Userpace should just let the user pick the country at say,
distribution install time, and the map then used to determine the
regulatory domain. Regulatory domains are what dictate the subband
restrictions and as such these are ultimately what we need in the
stack to decide what goes and what doesn't.

  Luis
