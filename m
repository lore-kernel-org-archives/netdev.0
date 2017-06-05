From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 06/19] net: bridge: Receive notification about
 successful FDB offload
Date: Mon, 5 Jun 2017 16:44:59 +0300
Message-ID: <9aacb99b-c209-3bf2-d0ee-35e2f009a1db@cumulusnetworks.com>
References: <20170605092043.3523-1-jiri@resnulli.us>
 <20170605092043.3523-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34392 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdFENpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 09:45:02 -0400
Received: by mail-wm0-f49.google.com with SMTP id 123so22840720wmg.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 06:45:01 -0700 (PDT)
In-Reply-To: <20170605092043.3523-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/17 12:20, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> When a new static FDB is added to the bridge a notification is sent to
> the driver for offload. In case of successful offload the driver should
> notify the bridge back, which in turn should mark the FDB as offloaded.
> 
> Currently, externally learned is equivalent for being offloaded which is
> not correct due to the fact that FDBs which are added from user-space are
> also marked as externally learned. In order to specify if an FDB was
> successfully offloaded a new flag is introduced.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/switchdev.h        |  1 +
>  include/uapi/linux/neighbour.h |  1 +
>  net/bridge/br.c                | 11 ++++++++++-
>  net/bridge/br_fdb.c            | 22 +++++++++++++++++++++-
>  net/bridge/br_private.h        |  5 ++++-
>  5 files changed, 37 insertions(+), 3 deletions(-)
> 

Overall the patch looks good to me, one thing to note is that there's a race
window between the call to br_fdb_external_learn_add() and br_fdb_offloaded_set()
where a sw port can take over the entry (and thus set added_by_external_learn = 0)
but have br_fdb_offloaded_set() set its offloaded flag to 1. Now I know the bridge
generally has these known race conditions between fdb flag manipulations so just wanted
to mention it.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
