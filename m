From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 20/27] sctp: add rfc6525 section 5.2.2
Date: Sun, 1 Jan 2017 21:23:44 +0800
Message-ID: <CADvbK_cO9bs+wDkwtpxutjbySv8xhQwRYWeNaKir_-dok0yW-g@mail.gmail.com>
References: <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
 <201701011927.G3TLoJx9%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        davem <davem@davemloft.net>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36301 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755085AbdAANXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 08:23:46 -0500
In-Reply-To: <201701011927.G3TLoJx9%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 1, 2017 at 8:02 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Xin,
>
> [auto build test WARNING on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Xin-Long/sctp-implement-rfc6525-sctp-stream-reconf/20170101-192844
> config: x86_64-randconfig-x015-201701 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
>
> All warnings (new ones prefixed by >>):
>
>    net/sctp/stream.c: In function 'sctp_process_strreset_outreq':
>>> net/sctp/stream.c:140:9: warning: 'str_p' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      *evp = sctp_ulpevent_make_stream_reset_event(asoc,
>             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>       flags | SCTP_STREAM_RESET_OUTGOING_SSN, nums, str_p,
>       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>       GFP_ATOMIC);
>       ~~~~~~~~~~~
>
This warning is actually safe, as only when nums is NULL, str_p is
uninitialized, and in sctp_ulpevent_make_stream_reset_event(), if nums
is null, str_p wouldn't be really used.

> vim +/str_p +140 net/sctp/stream.c
>
>    124                          if (str_p[i] >= asoc->streamincnt) {
>    125                                  result = SCTP_STRRESET_ERR_WRONG_SSN;
>    126                                  goto out;
>    127                          }
>    128                  }
>    129
>    130                  str_p = outreq->list_of_streams;
>    131                  for (i = 0; i < nums; i++, str_p++)
>    132                          asoc->streamin[*str_p].ssn = 0;
>    133          } else {
>    134                  for (i = 0; i < asoc->streamincnt; i++)
>    135                          asoc->streamin[i].ssn = 0;
>    136          }
>    137
>    138          result = SCTP_STRRESET_PERFORMED;
>    139
>  > 140          *evp = sctp_ulpevent_make_stream_reset_event(asoc,
>    141                  flags | SCTP_STREAM_RESET_OUTGOING_SSN, nums, str_p,
>    142                  GFP_ATOMIC);
>    143
>    144  out:
>    145          return sctp_make_strreset_resp(asoc, result, request_seq);
>    146  }
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
