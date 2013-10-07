From: Steve Rago <sar@nec-labs.com>
Subject: Re: bug in passing file descriptors
Date: Mon, 7 Oct 2013 15:06:02 -0400
Message-ID: <5253061A.7060701@nec-labs.com>
References: <5252FD2B.5040800@nec-labs.com> <CALCETrXmmW-nRTr4-yWJnNr2GWW37KW-7B1m=kSRnmYjhMTajA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nec-labs.com ([138.15.200.209]:51972 "EHLO
	mail.nec-labs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab3JGTGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:06:08 -0400
In-Reply-To: <CALCETrXmmW-nRTr4-yWJnNr2GWW37KW-7B1m=kSRnmYjhMTajA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2013 02:44 PM, Andy Lutomirski wrote:
>
> ISTM that, in order for further cmsgs to be correctly decoded, all of
> the relevant things need to match.
>
> put_cmsg uses this layout: cmsghdr, padding, payload, padding.
> CMSG_SPACE matches that calculation.
>
> scm_detach_fds is the actual code path for SCM_RIGHTS.  It does the same thing.
>
> CMSG_DATA also things that there's possible padding after cmsghdr.
>
> So I think everything's okay.
>
> --Andy
>

Maybe.  So a client expecting to receive x bytes of control information should make sure their buffer is at least 
CMSG_SPACE(x) bytes long instead of CMSG_LEN(x) bytes long, because you feel compelled to copy the final padding from 
kernel space to user space?  Seems wrong to me.  IMHO, the final padding should only come into play when calculating 
where the next header should begin.

Steve
