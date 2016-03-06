From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] ifstat, nstat: fix daemon mode
Date: Sun, 6 Mar 2016 12:50:51 -0800
Message-ID: <20160306125051.5d9e3425@xeon-e3>
References: <1456934187-4843-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47203 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865AbcCFUuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 15:50:44 -0500
In-Reply-To: <1456934187-4843-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Mar 2016 16:56:27 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Since the relevant code (and it's bugs) is identical in both files, fix
> them in one go. This patch fixes multiple issues:
> 
> * Using 'int' for the 'tdiff' variable does not suffice on 64bit
>   systems, the assigned initial time difference makes it wrap and
>   contain a negative value afterwards. Instead use the more appropriate
>   'time_t' type.
> 
> * As far as I understood the code, poll() is supposed to time out just
>   at the right time to trigger update_db() in the configured interval.
>   Therefore it's timeout must be set to the desired interval *minus* the
>   time that has already passed since then.
> 
> * With the last change to the algorithm in place, it does not make sense
>   to call update_db() before returning data to the connected client.
>   Actually, it never does otherwise we could skip the periodic updates
>   in the first place.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
