From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Tue, 25 Oct 2016 18:36:39 +0100
Message-ID: <20161025183639.69d2fa50@jkicinski-Precision-T1700>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, tom@herbertland.com, netdev@vger.kernel.org,
        shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shrijeet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:55842 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759418AbcJYRgs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 13:36:48 -0400
In-Reply-To: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Oct 2016 04:07:23 +0000, Shrijeet Mukherjee wrote:
> +		act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +		switch (act) {
> +		case XDP_PASS:
> +			return XDP_PASS;
> +		case XDP_TX:
> +		case XDP_ABORTED:
> +		case XDP_DROP:
> +			return XDP_DROP;
> +		default:
> +			bpf_warn_invalid_xdp_action(act);
> +		}
> +	}
> +	return XDP_PASS;

FWIW you may want to move the default label before XDP_TX/XDP_ABORT,
to get the behaviour to be drop on unknown ret code.
