From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 11/17] Tools: hv: Gather DNS information
Date: Wed, 25 Jul 2012 00:38:09 +0100
Message-ID: <20120724233809.GC1894@decadent.org.uk>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-11-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343145701-3691-11-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2012 at 09:01:35AM -0700, K. Y. Srinivasan wrote:
> Now gather DNS information. This information cannot be gathered in
> a distro independent fashion. Invoke an external script (that can be
> distro dependent) to gather the DNS information.
[...]
> +	memset(cmd, 0, sizeof(cmd));
> +	strcat(cmd, "/sbin/hv_get_dns_info ");
> +	strcat(cmd, if_name);
[...]

This is a weird way to build a string; why are you not using
snprintf()?  Not to mention that interface names can contain several
characters that are special to the shell - in fact the only disallowed
characters are / and whitespace.
 
Also, the external script will not be useful to anything other than
hv_kvp_daemon, so it probably belongs somewhere under /usr/share.
 
Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
