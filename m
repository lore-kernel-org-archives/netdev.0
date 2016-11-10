From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Thu, 10 Nov 2016 10:56:39 +0100
Message-ID: <20161110105639.6e8b70f7@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-5-git-send-email-pshelar@ovn.org>
        <20161109174138.410b4385@griffin>
        <CAOrHB_BwcJ0K3YcqPrVkKxFjWX9DFT1NjS3BbrcNtKQ_p_y44w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45230 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752513AbcKJJ4m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 04:56:42 -0500
In-Reply-To: <CAOrHB_BwcJ0K3YcqPrVkKxFjWX9DFT1NjS3BbrcNtKQ_p_y44w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Nov 2016 19:34:06 -0800, Pravin Shelar wrote:
> Why it would not help in non-ovs vxlan egress path? It avoids checking
> (if condition) for device loop.

I may be missing something but I count the same number of conditions
for each packet, they're just at a different place after the patch.

E.g. for IPv4, the "if (!sock4)" is moved from vxlan_xmit_one into
vxlan_get_route and the "rt" error handling stays logically the same
(three if conditions in the non-error path) but is moved into
vxlan_get_route. Similarly for IPv6.

 Jiri
