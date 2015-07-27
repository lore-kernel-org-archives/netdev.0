From: Cong Wang <cwang@twopensource.com>
Subject: Re: netns refcnt leak for kernel accept sock
Date: Mon, 27 Jul 2015 11:37:35 -0700
Message-ID: <CAHA+R7PzsOCR-UmJ+73jXJaacc_adz9F3-Qs4zB0cSFajpJREw@mail.gmail.com>
References: <20150727142146.GC16447@oracle.com>
	<CAHA+R7Pe08rfERd1rMR1Y_kK2iUm4TDc92rRhhJhr-e+_fsioA@mail.gmail.com>
	<20150727181946.GJ16447@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34754 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbG0Shg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:37:36 -0400
Received: by ykax123 with SMTP id x123so76650432yka.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:37:35 -0700 (PDT)
In-Reply-To: <20150727181946.GJ16447@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2015 at 11:19 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (07/27/15 11:13), Cong Wang wrote:
>>
>> That refcnt should be released in sock destructor too, when the tcp
>> connection is terminated.
>
> yes, but in my case, the listen socket is opened as part of
> the ->init indirection in pernet_operations (thus it is a kernel socket)
> and the expectation is that this listen socket, and any accept sockets
> derived from it, will be closed in ->exit.
>
> But if the accept socket is treated as a uspace socket (thus holds a get_net())
> then it will block cleanup_net() and the associated ->exit cleanup operations.
>
> This is probably not a problem for other systems like vxlan/gue/geneve etc
> because they all use udp sockets, thus dont have the "accept" equivalent.
>

dlm uses a kernel TCP socket too, but it allocates a new socket and calls
->accept() by itself. ;)
