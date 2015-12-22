From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH 00/17] CALIPSO implementation
Date: Tue, 22 Dec 2015 09:28:37 -0800
Message-ID: <56798845.6050703@schaufler-ca.com>
References: <1450784813-18304-1-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Huw Davies <huw@codeweavers.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1450784813-18304-1-git-send-email-huw@codeweavers.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/22/2015 3:46 AM, Huw Davies wrote:
> This patch series implements RFC 5570 - Common Architecture Label IPv6
> Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
> on IPv6 packets using a hop-by-hop option.  CALIPSO very similar to
> its IPv4 cousin CIPSO and much of this series is based on that code.

There's a one line change to the Smack code in 15/17 due to
a change in the api, but I assume that there has been no
attempt to verify that this works with Smack. It's not 100%
clear that this won't break a Smack kernel, but I haven't
tried it.

You'll need to provide sufficient information (or code!) so
that security modules other than SELinux can use this. If
you look at how Smack uses netlabel for IPv4 you will see
that it differs substantially from the way SELinux uses it.

Thank you for tackling RFC 5570. The lack of something like
this has put IPv6 at a real disadvantage.

>
> Most of this series involves adding support to NetLabel and adding a
> CALIPSO module within IPv6, and as such is fairly self-contained.
> There are however a few places where I've needed to add things to the
> core networking stack, so I'd be particularly interested in hearing
> comments about these:
>
> [PATCH 08/17] ipv6: Add ipv6_renew_options_kern() that accepts a kernel mem pointer.
>   Hopefully not too controversial - adds a kernel memory version of
>   ipv6_renew_options()
>
> [PATCH 12/17] ipv6: Allow request socks to contain IPv6 options.
>   We need a way to set the IPv6 options on request sockets, just like
>   we do for IPv4.  This is so that the LSM can ensure the SYN-ACK is
>   correctly labelled.
>
> The series is based off v4.4-rc6.
>
> Thoughts about these and any of the other patches are most welcome.
>
> If anybody actually wants to play with this, then you'll need some patches
> to netlabel-tools that are currently available on the 'calipso' branch at:
> https://github.com/hdmdavies/netlabel_tools.git
>
> Thanks to Paul Moore for his guidance in getting this far.
>
> Huw.
> _______________________________________________
> Selinux mailing list
> Selinux@tycho.nsa.gov
> To unsubscribe, send email to Selinux-leave@tycho.nsa.gov.
> To get help, send an email containing "help" to Selinux-request@tycho.nsa.gov.
>

