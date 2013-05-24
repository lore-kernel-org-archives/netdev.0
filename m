From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable when
 performing the upcall
Date: Fri, 24 May 2013 10:24:50 -0700
Message-ID: <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
References: <cover.1369406826.git.tgraf@suug.ch> <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:48093 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756056Ab3EXRZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 13:25:12 -0400
Received: by mail-ie0-f176.google.com with SMTP id at1so12546139iec.7
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 10:25:12 -0700 (PDT)
In-Reply-To: <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 7:52 AM, Thomas Graf <tgraf@suug.ch> wrote:
> From: Thomas Graf <tgraf@rhlap.localdomain>
>
> Avoids a memcpy() that is expensive for large packets:
>
> from:
>   4.51%  [kernel]                      [k] memcpy
> to:
>   1.20%  [kernel]                      [k] memcpy
>   1.01%  [kernel]                      [k] skb_zerocopy
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Does this have any impact on small packets? Those are usually the
common case (i.e. TCP SYN) and I think this is slightly less optimal
for those.
