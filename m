From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 14 Oct 2008 09:10:10 +0200
Message-ID: <7e0dd21a0810140010n591922b8habba8869ba7d95d2@mail.gmail.com>
References: <20080922070425.GA14572@2ka.mipt.ru>
	 <E1Khzut-0006lv-Co@gondolin.me.apana.org.au>
	 <20080923062709.GA7886@2ka.mipt.ru>
	 <20080923070133.GB26836@gondor.apana.org.au>
	 <20080924005335.0117c536.billfink@mindspring.com>
	 <7e0dd21a0810140009k49c8876ax66f744d0a3a4931b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"David Miller" <davem@davemloft.net>,
	"Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:54331 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbYJNHKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 03:10:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2233043rvb.1
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 00:10:10 -0700 (PDT)
In-Reply-To: <7e0dd21a0810140009k49c8876ax66f744d0a3a4931b@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I'm sorry for this late reply but I was out of Internet access during one month.
So if my understanding is correct, sendfile() over UDP can't be used
to send a file > 64 ko in one system call, as each request must fit in
one UDP packet.

However is it expected that sendfile() returns 64Ko but sends nothing
over the network when we are performing this particular case
(file>64ko)? should it return 0?

Thanks in advance,
Johann

>
>
>
> On Wed, Sep 24, 2008 at 6:53 AM, Bill Fink <billfink@mindspring.com> wrote:
>>
>> On Tue, 23 Sep 2008, Herbert Xu wrote:
>>
>> > On Tue, Sep 23, 2008 at 10:27:10AM +0400, Evgeniy Polyakov wrote:
>> > > On Tue, Sep 23, 2008 at 12:54:27PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
>> > > > I think this dicussion is moot since the only time you want to use
>> > > > sendfile is for bulk transfers and these days anybody designing new
>> > > > applications that does bulk transfers over UDP should be taken out
>> > > > and shot.
>> > >
>> > > One can protect himself pointing how slow may be memory bus in some
>> > > hardware setup, which completely does not allow to perform any copy.
>> >
>> > Yes but bulk transfers over UDP is a bad idea regardless of how
>> > slow your bus is :)
>> >
>> > So what application needs this?
>>
>> It seems it might be useful for a video server.  The one thing that
>> seems to be missing from the sendfile() semantics is a message size
>> to be used for splitting the file into UDP datagrams, but this could
>> be provided by a separate ioctl(), and could default to the largest
>> message size that would fit in the MTU.
>>
>>                                                -Bill
>
>
>
> --
> Johann Baudy
> johaahn@gmail.com



--
Johann Baudy
johaahn@gmail.com
