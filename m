From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [RFC PATCH 4/5] bnxt: Add support for segmentation of tunnels
 with outer checksums
Date: Tue, 26 Apr 2016 22:55:04 -0700
Message-ID: <CACKFLi=2mHfOS1Rz5RbSdyhepdjBqM+dj7Nh=CzARcYSwUTcSw@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
	<20160419190615.11723.53966.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eugenia@mellanox.com, bruce.w.allan@intel.com, saeedm@mellanox.com,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	ariel.elior@qlogic.com, Michael Chan <mchan@broadcom.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33765 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbcD0FzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 01:55:06 -0400
Received: by mail-ob0-f181.google.com with SMTP id x1so105663obt.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 22:55:05 -0700 (PDT)
In-Reply-To: <20160419190615.11723.53966.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 12:06 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch assumes that the bnxt hardware will ignore existing IPv4/v6
> header fields for length and checksum as well as the length and checksum
> fields for outer UDP and GRE headers.
>
> I have no means of testing this as I do not have any bnx2x hardware but
> thought I would submit it as an RFC to see if anyone out there wants to
> test this and see if this does in fact enable this functionality allowing
> us to to segment tunneled frames that have an outer checksum.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Hi Alex, I just did a very quick test of this patch on our bnxt
hardware and it seemed to work.

I created a vxlan endpoint with udpcsum enabled and I saw TSO packets
getting through.  I've verified that our hardware can be programmed to
either ignore outer UDP checksum or to calculate it.  Current default
is to ignore ipv4 UDP checksum and calculate ipv6 UDP checksum.
Thanks.

> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
