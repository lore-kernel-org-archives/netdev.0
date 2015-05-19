From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/4] rocker: transaction fixes
Date: Tue, 19 May 2015 09:13:58 -0700
Message-ID: <CAE4R7bAKTw-SPQNqsKsEf_BhXJhqDFPWu6rsgX2=+7Jjh8FL7g@mail.gmail.com>
References: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:36724 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756385AbbESQN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 12:13:58 -0400
Received: by qcir1 with SMTP id r1so9650441qci.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 09:13:58 -0700 (PDT)
In-Reply-To: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 11:24 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi,
>
> this series addresses what appear to be errors in the handling of
> prepare and then commit transactions in the rocker driver.
>
> In all cases the problem is that data structures visible outside of
> the transaction are modified during the prepare phase.
>
> In the case of the first two patches this results in the kernel reporting a
> BUG. I have noted test-cases in the change logs.
>
> The remaining two patches do not fix bugs that manifest as far as
> I can tell. Rather, they are correctness fixes.
>
> Simon Horman (4):
>   rocker: do not delete fdb entries in rocker_port_fdb_flush() when
>     preparing transactions
>   rocker: do not modify fdb table in rocker_port_fdb() when preparing
>     transactions
>   rocker: do not make neighbour entry changes when preparing
>     transactions
>   rocker: make rocker_port_internal_vlan_id_{get,put}()
>     non-transactional
>
>  drivers/net/ethernet/rocker/rocker.c | 46 ++++++++++++++++++++----------------
>  1 file changed, 25 insertions(+), 21 deletions(-)

Thank you very much Simon for the fixes.  I think for punishment in
missing these I'm going to write unit tests for each.

-scott
