From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 31232] New: /proc/sys/net/ipv6 has two neigh
 folders
Date: Wed, 16 Mar 2011 15:23:00 -0700
Message-ID: <20110316152300.360f9240.akpm@linux-foundation.org>
References: <bug-31232-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>, sunkan@zappa.cx
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39143 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792Ab1CPWXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 18:23:24 -0400
In-Reply-To: <bug-31232-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 16 Mar 2011 22:06:34 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=31232
> 
>            Summary: /proc/sys/net/ipv6 has two neigh folders
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: sunkan@zappa.cx
>         Regression: No
> 
> 
> I noticed when looking for other things that there are two neigh folders in
> /proc/sys/net/ipv6
> 
> Reverting this commit removes the extra neigh folder:
> http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=bf36076a67db6d7423d09d861a072337866f0dd9
> 
> I don't know how to fix this.
> I tried removing the ',' on the row '.child = empty,' (looking at the other
> rows it did seem like a typo to me).
> 
> This did not change anything that I could see though.
> 
> Here is the commit I believe introduced the bug: 
> 
> --- a/net/ipv6/sysctl_net_ipv6.c
> +++ b/net/ipv6/sysctl_net_ipv6.c
> @@ -15,6 +15,8 @@
>  #include <net/addrconf.h>
>  #include <net/inet_frag.h>
> 
> +static struct ctl_table empty[1];
> +
>  static ctl_table ipv6_table_template[] = {
>         {
>                 .procname       = "route",
> @@ -35,6 +37,12 @@ static ctl_table ipv6_table_template[] = {
>                 .mode           = 0644,
>                 .proc_handler   = proc_dointvec
>         },
> +       {
> +               .procname       = "neigh",
> +               .maxlen         = 0,
> +               .mode           = 0555,
> +               .child          = empty,
> +       },
>         { }
>  };
> 
> @@ -152,7 +160,6 @@ static struct ctl_table_header *ip6_base;
> 
>  int ipv6_static_sysctl_register(void)
>  {
> -       static struct ctl_table empty[1];
>         ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
>         if (ip6_base == NULL)
>                 return -ENOMEM;
> 

