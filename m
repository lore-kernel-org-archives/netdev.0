From: Asim Shankar <asimshankar@gmail.com>
Subject: Re: SNAT help
Date: Tue, 10 May 2005 12:12:20 -0500
Message-ID: <7bca1cb505051010123f0d0a26@mail.gmail.com>
References: <20050509083113.42571.qmail@web41414.mail.yahoo.com>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: net dev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20050509083113.42571.qmail@web41414.mail.yahoo.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> i have enabled SNAT and I have wrriten code
> at NF_IP_POST_ROUTING but i want to get outgoing
> packets' IP address as new one SNAT'ed IP address not
> the one that is before SNAT? How can i do that?

I think changing the priority (struct nf_hook_ops.priority) when
registering the hook would do your job. ip_nat_out_ops registers a
hook with a priority NF_IP_PRI_NAT_SRC.

If you register your hook with a priority greater than
NF_IP_PRI_NAT_SRC (like (NF_IP_PRI_NAT_SRC + 1) or NF_IP_PRI_LAST)
then your hook will be called after the ip_nat_out_ops hook.

Hope that helps,

-- Asim
