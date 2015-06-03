From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface link status
Date: Tue, 2 Jun 2015 22:03:23 -0700
Message-ID: <CAE4R7bDHsoaN6spkOW5jk94wB3wkUBd-j+y3H47611CxZUT6ag@mail.gmail.com>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:35262 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbFCFDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 01:03:44 -0400
Received: by qczw4 with SMTP id w4so44296836qcz.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 22:03:43 -0700 (PDT)
In-Reply-To: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> This patch adds the ability to have the Linux kernel track whether or
> not a particular route should be used based on the link-status of the
> interface associated with the next-hop.
>
> Before this patch any link-failure on an interface that was serving as a
> gateway for some systems could result in those systems being isolated
> from the rest of the network as the stack would continue to attempt to
> send frames out of an interface that is actually linked-down.  When the
> kernel is responsible for all forwarding, it should also be responsible
> for taking action when the traffic can no longer be forwarded -- there
> is no real need to outsource link-monitoring to userspace anymore.

Hi Andy, how does this work for the hardware offload case?  I'm not
seeing how hardware gets updated when the software route is updated.
Seems hardware isn't updated and would send frames out the downed nh
interface.

-scott
