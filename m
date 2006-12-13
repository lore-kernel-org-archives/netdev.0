From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] add init_dummy_netdev() for napi only dummy intefaces
Date: Wed, 13 Dec 2006 11:35:37 -0800
Message-ID: <20061213113537.6baf410f@dxpl.pdx.osdl.net>
References: <1165901258.11914.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34015 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932671AbWLMTfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 14:35:45 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1165901258.11914.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Dec 2006 16:27:38 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> This adds an init_dummy_netdev() function that gets a network device
> structure (allocation and lifetime entirely under caller's control) and
> initialize the minimum amount of fields so it can be used to schedule
> NAPI polls without registering a full blown interface. This is to be
> used by drivers that need to tie several hardware interfaces to a single
> NAPI poll scheduler due to HW limitations.
> 
> It also updates the ibm_emac driver to use that instead of doing it's
> own initializations by hand.
> 
> Symbol is exported GPL only a I don't think we want binary drivers doing
> that sort of acrobatics (if we want them at all).
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---

Could we split off the NAPI context part of network_device instead?
I'll work up something for 2.6.21.
