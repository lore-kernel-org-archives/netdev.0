From: "Julius Volz" <julius.volz@gmail.com>
Subject: Re: %pI4 vs. NIPQUAD: %pI4 doing it wrong?
Date: Tue, 4 Nov 2008 02:11:25 +0100
Message-ID: <43ca39800811031711s4c8fe574o8baddb245f0702ff@mail.gmail.com>
References: <15026.1225760729@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Harvey Harrison" <harvey.harrison@gmail.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:24719 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbYKDBL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:11:26 -0500
Received: by an-out-0708.google.com with SMTP id d40so158628and.1
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 17:11:25 -0800 (PST)
In-Reply-To: <15026.1225760729@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Jay,

I noticed the same thing and Harvey already posted a fix - Dave just
applied it a second ago :)

Julius

On Tue, Nov 4, 2008 at 2:05 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>        Running the latest net-next-2.6, I notice that %pI4 is
> apparently printing IPv4 addresses incorrectly (and differently than the
> NIPQUAD it replaced).
>
>        The following is excerpted from the bonding driver's
> /proc/net/bonding/bond0 status file:
>
> [...]
> ARP IP target/s (n.n.n.n form): 01.0.1.1 (10.0.1.1), 01.02.03.04 (10.20.30.40)
>
>        The first (incorrect) values are from %pI4, the ones in
> parentheses (which are correct) I added as a check using NIPQUAD with
> this patch:
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 56c823c..ced12ba 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3289,7 +3289,9 @@ static void bond_info_show_master(struct seq_file *seq)
>                                continue;
>                        if (printed)
>                                seq_printf(seq, ",");
> -                       seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
> +                       seq_printf(seq, " %pI4 (%u.%u.%u.%u)",
> +                                  &bond->params.arp_targets[i],
> +                                  NIPQUAD(bond->params.arp_targets[i]));
>                        printed = 1;
>                }
>                seq_printf(seq, "\n");
>
>        Is anybody else seeing this, or is it just me?
>
>        I'm working on an x86.
>
>        -J
>
> ---
>        -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
