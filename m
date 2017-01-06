From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 net-next] sctp: prepare asoc stream for stream reconf
Date: Fri, 6 Jan 2017 15:50:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB025926D@AcuExch.aculab.com>
References: <efd6462731ca0b18a3039f9537dda61e0ed72430.1483712313.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:54913 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934137AbdAFPuo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 10:50:44 -0500
In-Reply-To: <efd6462731ca0b18a3039f9537dda61e0ed72430.1483712313.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 06 January 2017 14:19
> sctp stream reconf, described in RFC 6525, needs a structure to
> save per stream information in assoc, like stream state.
> 
> In the future, sctp stream scheduler also needs it to save some
> stream scheduler params and queues.
> 
> This patchset is to prepare the stream array in assoc for stream
> reconf. It defines sctp_stream that includes stream arrays inside
> to replace ssnmap.
> 
> Note that we use different structures for IN and OUT streams, as
> the members in per OUT stream will get more and more different
> from per IN stream.
...
>  /* What is the current SSN number for this stream? */
> -static inline __u16 sctp_ssn_peek(struct sctp_stream *stream, __u16 id)
> -{
> -	return stream->ssn[id];
> -}
> +#define sctp_ssn_peek(stream, type, sid) \
> +	((stream)->type[sid].ssn)
> 
>  /* Return the next SSN number for this stream.	*/
> -static inline __u16 sctp_ssn_next(struct sctp_stream *stream, __u16 id)
> -{
> -	return stream->ssn[id]++;
> -}
> +#define sctp_ssn_next(stream, type, sid) \
> +	((stream)->type[sid].ssn++)
> 
>  /* Skip over this ssn and all below. */
> -static inline void sctp_ssn_skip(struct sctp_stream *stream, __u16 id,
> -				 __u16 ssn)
> -{
> -	stream->ssn[id] = ssn+1;
> -}
> -
> +#define sctp_ssn_skip(stream, type, sid, ssn) \
> +	((stream)->type[sid].ssn = ssn + 1)
...

Is there any reason to convert these from inline functions to #defines?
Inline functions give better type checking and are usually preferred.

	David
