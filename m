From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: declare struct sctp_stream before using it
Date: Tue, 21 Mar 2017 07:36:48 -0400
Message-ID: <20170321113648.GA29216@hmswarspite.think-freely.org>
References: <1a16b414118d0876373774654d86e2a2a936b9d1.1490003187.git.lucien.xin@gmail.com>
 <20170320132920.GA7855@hmswarspite.think-freely.org>
 <CADvbK_ffhWRSkzESfar9JRUUX_defGdM4hiPrVz5ZQS6yNjG3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53043 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757031AbdCUMwY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 08:52:24 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_ffhWRSkzESfar9JRUUX_defGdM4hiPrVz5ZQS6yNjG3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 10:33:57PM +0800, Xin Long wrote:
> On Mon, Mar 20, 2017 at 9:29 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> > On Mon, Mar 20, 2017 at 05:46:27PM +0800, Xin Long wrote:
> >> sctp_stream_free uses struct sctp_stream as a param, but struct sctp_stream
> >> is defined after it's declaration.
> >>
> >> This patch is to declare struct sctp_stream before sctp_stream_free.
> >>
> >> Fixes: a83863174a61 ("sctp: prepare asoc stream for stream reconf")
> >> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> >> ---
> >>  include/net/sctp/structs.h | 1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> >> index 4f64519..592dece 100644
> >> --- a/include/net/sctp/structs.h
> >> +++ b/include/net/sctp/structs.h
> >> @@ -83,6 +83,7 @@ struct sctp_bind_addr;
> >>  struct sctp_ulpq;
> >>  struct sctp_ep_common;
> >>  struct crypto_shash;
> >> +struct sctp_stream;
> >>
> >>
> >>  #include <net/sctp/tsnmap.h>
> >> --
> >> 2.1.0
> >>
> >>
> >
> > Not sure I follow.  did we run into a compilation failure here?
> no compilation err was found, even now.
> 
> because of
> struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp);
> void sctp_stream_free(struct sctp_stream *stream);
> 
> I'm not sure why gcc did not complain, but when I moved sctp_stream_new
> below sctp_stream_free:
> void sctp_stream_free(struct sctp_stream *stream);
> struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp);
> 
> the err showed up.
> 
odd, its almost like gcc considered the return value of sctp_stream_new to be a
forward declaration of the struct.

Anywho, can't hurt to make this chagne
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> So the better thing we should do is to declare struct sctp_stream to
> avoid this potential issue.
> 
> Besides, I'm planing to change the return value type of sctp_stream_new.
> after which, the issue will be exposed.
> 
> >
> > Neil
> >
> 
