From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Sun, 23 Mar 2008 14:00:41 +0100
Message-ID: <200803231400.41397.vda.linux@googlemail.com>
References: <47CE8FF7.7000701@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:38210 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755883AbYCWNCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 09:02:09 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2438695fgb.17
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2008 06:02:08 -0700 (PDT)
In-Reply-To: <47CE8FF7.7000701@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 March 2008 13:20, Pavel Emelyanov wrote:
> Current /proc/net is done with so called "shadows", but current
> implementation is broken and has little chances to get fixed.
> 
> The problem is that dentries subtree of /proc/net directory has
> fancy revalidation rules to make processes living in different
> net namespaces see different entries in /proc/net subtree, but
> currently, tasks see in the /proc/net subdir the contents of any
> other namespace, depending on who opened the file first.
> 
> The proposed fix is to turn /proc/net into a symlink, which points
> to /proc/self/net, which in turn shows what previously was in
> /proc/net - the network-related info, from the net namespace the
> appropriate task lives in.
> 
> # ls -l /proc/net
> lrwxrwxrwx  1 root root 8 Mar  5 15:17 /proc/net -> self/net

This broke tools which read /proc/net/dev. Under non-root,
they are no longer working. This is a regression.
--
vda
