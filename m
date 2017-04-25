From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC 3/4] nfp: make use of extended ack message reporting
Date: Tue, 25 Apr 2017 08:42:32 -0400
Message-ID: <9765d004-de19-7cf2-fcfc-1d2e72cded43@mojatatu.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
 <20170425080644.122536-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34861 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430500AbdDYMmg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 08:42:36 -0400
Received: by mail-it0-f65.google.com with SMTP id 70so2725295ita.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 05:42:36 -0700 (PDT)
In-Reply-To: <20170425080644.122536-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good stuff. Question below:

On 17-04-25 04:06 AM, Jakub Kicinski wrote:
> Try to carry error messages to the user via the netlink extended

[..]
> +nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
> +		     struct netlink_ext_ack *extack)
>  {
>  	/* XDP-enabled tests */
>  	if (!dp->xdp_prog)
>  		return 0;
>  	if (dp->fl_bufsz > PAGE_SIZE) {
> -		nn_warn(nn, "MTU too large w/ XDP enabled\n");
> +		NL_SET_ERR_MSG(extack, "MTU too large w/ XDP enabled");

So are we going to standardize these strings?
i.e what if some user has written a bash script that depends on this
string and it gets changed later.

cheers,
jamal
