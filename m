From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Re: iproute2: potential upgrade regression with
 58a3e827
Date: Fri, 13 Dec 2013 10:55:03 -0800
Message-ID: <20131213105503.7a12ab18@nehalam.linuxnetplumber.net>
References: <527D2768.1030403@canonical.com>
	<527E6A32.5020808@hp.com>
	<52814B88.1050708@canonical.com>
	<1384205890.2758.28.camel@dilip-laptop>
	<871u2mblzk.fsf@xmission.com>
	<1384216612.2758.30.camel@dilip-laptop>
	<52AB55F1.8000301@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dilip.daya@hp.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	Brian Haley <brian.haley@hp.com>, shemminger@osdl.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:50877 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab3LMSzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:55:07 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so2856782pde.13
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:55:06 -0800 (PST)
In-Reply-To: <52AB55F1.8000301@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Dec 2013 12:46:09 -0600
Chris J Arges <chris.j.arges@canonical.com> wrote:

> @@ -424,6 +424,7 @@ static int netns_add(int argc, char **argv)
>  		}
>  
>  		/* Upgrade NETNS_RUN_DIR to a mount point */
> +		errno = 0;
>  		if (mount(NETNS_RUN_DIR, NETNS_RUN_DIR, "none", MS_BIND, NULL)) {
>  			fprintf(stderr, "mount --bind %s %s failed: %s\n",
>  				NETNS_RUN_DIR, NETNS_RUN_DIR, strerror(errno));

It doesn't make sense that this changes anything.
errno is set by failed syscall. And the code here is smart enough
not to blindly check for (errno != 0)
