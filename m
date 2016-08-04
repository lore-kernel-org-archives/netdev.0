From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/3] sctp: Export struct sctp_info to userspace
Date: Thu, 4 Aug 2016 09:13:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F509220@AcuExch.aculab.com>
References: <1470259393-22861-1-git-send-email-phil@nwl.cc>
 <1470259393-22861-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:58903 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbcHDJPq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 05:15:46 -0400
In-Reply-To: <1470259393-22861-2-git-send-email-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 03 August 2016 22:23
> This is required to correctly interpret INET_DIAG_INFO messages exported
> by sctp_diag module.
...
> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> index de1f64318fc4e..fcb4c36461732 100644
> --- a/include/linux/sctp.h
> +++ b/include/linux/sctp.h
> @@ -705,70 +705,6 @@ typedef struct sctp_auth_chunk {
>  	sctp_authhdr_t auth_hdr;
>  } __packed sctp_auth_chunk_t;
> 
> -struct sctp_info {
> -	__u32	sctpi_tag;
...
> -	__u32	__reserved3;
> -};
> -
>  struct sctp_infox {
>  	struct sctp_info *sctpinfo;
>  	struct sctp_association *asoc;
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index d304f4c9792c4..a406adcc0793e 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -944,4 +944,68 @@ struct sctp_default_prinfo {
>  	__u16 pr_policy;
>  };
> 
> +struct sctp_info {
> +	__u32	sctpi_tag;

Should these be uint32_t (etc) for userspace?

> +	__u32	sctpi_state;
...
> +	__u16	__reserved1;

Is it worth adding some extra pad here in case anything extra needs
to be added to this set of data?

...
> +	__u32	__reserved3;

Think I'd definitely add a few words of pad here.
Or at least make absolutely sure the interface passes the buffer length and
allows for kernels that report different length buffers.

> +};

	David
