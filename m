From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] sctp: asconf's process should verify address
 parameter is in the beginning
Date: Mon, 24 Aug 2015 15:13:03 +0300
Message-ID: <55DB0A4F.8090004@cogentembedded.com>
References: <87d339ea910a3665c9376b6ba69b003af967c6d1.1440410878.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:33461 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbbHXMNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 08:13:04 -0400
Received: by lalv9 with SMTP id v9so75841428lal.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 05:13:02 -0700 (PDT)
In-Reply-To: <87d339ea910a3665c9376b6ba69b003af967c6d1.1440410878.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/24/2015 1:07 PM, Xin Long wrote:

> in sctp_process_asconf(), we get address parameter from the beginning of the
> addip params. but we never check if it's really there. if the addr param is not
> there, it still can pass sctp_verify_asconf(), then to be handled by
> sctp_process_asconf(), it will not be safe.
>
> so add a code in sctp_verify_asconf() to check the address parameter is in the
> beginning, or return false to send abort.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>   net/sctp/sm_make_chunk.c | 8 ++++++++
>   1 file changed, 8 insertions(+)

> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 0ee5ca7..a2a72d5 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3122,6 +3122,14 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>   	union sctp_params param;
>   	bool addr_param_seen = false;
>
> +	if(addr_param_needed){

    Space needed after *if*. Please run your patches thru 
scripts/checkpatch.pl before posting.

[...]

MBR, Sergei
