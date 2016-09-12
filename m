From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 1/6] sctp: remove the unnecessary state check in
 sctp_outq_tail
Date: Mon, 12 Sep 2016 16:48:38 -0300
Message-ID: <20160912194838.GE17689@localhost.localdomain>
References: <cover.1473326067.git.lucien.xin@gmail.com>
 <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
 <20160908142701.GC16608@hmsreliant.think-freely.org>
 <CADvbK_dxTYrPPFJT5UPZErZLbW9y9oRm+VWbQXxhruwV6UgOZA@mail.gmail.com>
 <20160908192319.GD16608@hmsreliant.think-freely.org>
 <CADvbK_ddvZ4855B1PPLYVY2JV1okKzYXCpv-quNMBXp0Qb5Otw@mail.gmail.com>
 <20160909142841.GB15908@hmsreliant.think-freely.org>
 <CADvbK_f-09NvfeCbeaZZF8+LuMASTYnrh+02RvTz5UR-huiR3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org, davem <davem@davemloft.net>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51826 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751400AbcILTsm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 15:48:42 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_f-09NvfeCbeaZZF8+LuMASTYnrh+02RvTz5UR-huiR3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 10, 2016 at 12:03:53AM +0800, Xin Long wrote:
> > That said, have you considered the retransmit case?  That is to say, if you
> > queue and flush the outq, and some packets fail delivery, and in the time
> > between the intial send and the expiration of the RTX timer (during which the
> > socket lock will have been released), an event may occur which changes the
> > transport state, which will then be ignored with your patch.
> Sorry, I'm not sure if I got it.
> 
> You mean "during which changes q->asoc->state", right ?
> 
> This patch removes the check of q->asoc->state in sctp_outq_tail().
> 
> sctp_outq_tail() is called for data only in:
> sctp_primitive_SEND -> sctp_do_sm -> sctp_cmd_send_msg ->
> sctp_cmd_interpreter -> sctp_cmd_send_msg() -> sctp_outq_tail()
> 
> before calling sctp_primitive_SEND, hold sock lock first.
> then sctp_primitive_SEND choose FUNC according:
> 
> #define TYPE_SCTP_PRIMITIVE_SEND  {
> ....
> 
> if asoc->state is unavailable, FUNC can't be sctp_cmd_send_msg,
> but sctp_sf_error_closed/sctp_sf_error_shutdown,  sctp_outq_tail
> can't be called, either.
> I mean sctp_primitive_SEND do the same check for asoc->state
> already actually.
> 
> so the code in sctp_outq_tail is redundant actually.

I also don't see an issue with this patch, btw.

Xin, you may want to add more/such details to the changelog, specially
about the timer versus primitive handling.

  Marcelo
