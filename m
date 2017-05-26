From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 0/6] nfp: devlink port implementation
Date: Fri, 26 May 2017 10:25:32 +0200
Message-ID: <20170526082532.GC1898@nanopsycho>
References: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34973 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759576AbdEZIZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:25:35 -0400
Received: by mail-wm0-f68.google.com with SMTP id g15so2328787wmc.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:25:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 26, 2017 at 10:03:30AM CEST, jakub.kicinski@netronome.com wrote:
>Hi!
>
>This series adds basic devlink support.  The operations we can perform
>are port show and port split/unsplit.
>
>v2:
>Register devlink first, and then register all the ports.  Port {,un}split
>searches the port list, which is protected by a mutex.  If port split
>is requested before ports are registered we will simply not find the port
>and return -EINVAL.

Looks fine to me now. Thanks!


>
>Jakub Kicinski (5):
>  nfp: move mutex init out of net code
>  nfp: add helper for cleaning up vNICs
>  nfp: register ports as devlink ports
>  nfp: calculate total port lanes for split
>  nfp: support port splitting via devlink
>
>Simon Horman (1):
>  nfp: add devlink support
>
> drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
> drivers/net/ethernet/netronome/nfp/nfp_devlink.c   | 181 +++++++++++++++++++++
> drivers/net/ethernet/netronome/nfp/nfp_main.c      |  28 +++-
> drivers/net/ethernet/netronome/nfp/nfp_main.h      |   3 +
> drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  61 ++++---
> drivers/net/ethernet/netronome/nfp/nfp_port.c      |  19 +++
> drivers/net/ethernet/netronome/nfp/nfp_port.h      |  12 ++
> .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |   3 +
> .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   |  11 +-
> 9 files changed, 289 insertions(+), 30 deletions(-)
> create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_devlink.c
>
>-- 
>2.11.0
>
