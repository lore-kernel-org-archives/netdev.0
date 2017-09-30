From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 00/10] Introduce SCTP Stream Schedulers
Date: Sun, 1 Oct 2017 00:52:38 +0800
Message-ID: <CADvbK_e9tizC1ROj0qa=tLVw5o_mrB-QJwQ4Ct94s8vubD+CkA@mail.gmail.com>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a114578d0233cb1055a6af8e1"
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Laight <David.Laight@aculab.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:53722 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751069AbdI3Qwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 12:52:40 -0400
In-Reply-To: <cover.1506536044.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114578d0233cb1055a6af8e1
Content-Type: text/plain; charset="UTF-8"

On Fri, Sep 29, 2017 at 4:25 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> This patchset introduces the SCTP Stream Schedulers are defined by
> https://tools.ietf.org/html/draft-ietf-tsvwg-sctp-ndata-13
>
> It provides 3 schedulers at the moment: FCFS, Priority and Round Robin.
> The other 3, Round Robin per packet, Fair Capacity and Weighted Fair
> Capacity will be added later. More specifically, WFQ is required by
> WebRTC Datachannels.
>
> The draft also defines the idata chunk, allowing a usermsg to be
> interrupted by another piece of idata from another stream. This patchset
> *doesn't* include it. It will be posted later by Xin Long.  Its
> integration with this patchset is very simple and it basically only
> requires a tweak in sctp_sched_dequeue_done(), to ignore datamsg
> boundaries.
>
> The first 5 patches are a preparation for the next ones. The most
> relevant patches are the 4th and 6th ones. More details are available on
> each patch.
>
> Marcelo Ricardo Leitner (10):
>   sctp: silence warns on sctp_stream_init allocations
>   sctp: factor out stream->out allocation
>   sctp: factor out stream->in allocation
>   sctp: introduce struct sctp_stream_out_ext
>   sctp: introduce sctp_chunk_stream_no
>   sctp: introduce stream scheduler foundations
>   sctp: add sockopt to get/set stream scheduler
>   sctp: add sockopt to get/set stream scheduler parameters
>   sctp: introduce priority based stream scheduler
>   sctp: introduce round robin stream scheduler
>
>  include/net/sctp/stream_sched.h |  72 +++++++++
>  include/net/sctp/structs.h      |  63 +++++++-
>  include/uapi/linux/sctp.h       |  16 ++
>  net/sctp/Makefile               |   3 +-
>  net/sctp/chunk.c                |   6 +-
>  net/sctp/outqueue.c             |  63 ++++----
>  net/sctp/sm_sideeffect.c        |   3 +
>  net/sctp/socket.c               | 179 ++++++++++++++++++++-
>  net/sctp/stream.c               | 196 +++++++++++++++++++----
>  net/sctp/stream_sched.c         | 275 +++++++++++++++++++++++++++++++
>  net/sctp/stream_sched_prio.c    | 347 ++++++++++++++++++++++++++++++++++++++++
>  net/sctp/stream_sched_rr.c      | 201 +++++++++++++++++++++++
>  12 files changed, 1347 insertions(+), 77 deletions(-)
>  create mode 100644 include/net/sctp/stream_sched.h
>  create mode 100644 net/sctp/stream_sched.c
>  create mode 100644 net/sctp/stream_sched_prio.c
>  create mode 100644 net/sctp/stream_sched_rr.c
>
> --
> 2.13.5
>
Attachment are the testcase based on:
https://github.com/sctp/sctp-tests

Tested-by: Xin Long <lucien.xin@gmail.com>

--001a114578d0233cb1055a6af8e1
Content-Type: application/x-gzip; name="ndatasched.tar.gz"
Content-Disposition: attachment; filename="ndatasched.tar.gz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j87k16tb0

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
--001a114578d0233cb1055a6af8e1--
