From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] af_unix: If we don't care about credentials
 coallesce all messages
Date: Fri, 05 Apr 2013 00:47:37 -0400 (EDT)
Message-ID: <20130405.004737.1210876879365869656.davem@davemloft.net>
References: <878v4zjei0.fsf@xmission.com>
	<87li8zhwkw.fsf_-_@xmission.com>
	<87d2ubhwiw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	dingtianhong@huawei.com, edumazet@google.com, luto@amacapital.net,
	ksrot@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ebiederm@xmission.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87d2ubhwiw.fsf_-_@xmission.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 03 Apr 2013 19:14:47 -0700

> 
> It was reported that the following LSB test case failed
> https://lsbbugs.linuxfoundation.org/attachment.cgi?id=2144 because we
> were not coallescing unix stream messages when the application was
> expecting us to.
> 
> The problem was that the first send was before the socket was accepted
> and thus sock->sk_socket was NULL in maybe_add_creds, and the second
> send after the socket was accepted had a non-NULL value for sk->socket
> and thus we could tell the credentials were not needed so we did not
> bother.
> 
> The unnecessary credentials on the first message cause
> unix_stream_recvmsg to start verifying that all messages had the same
> credentials before coallescing and then the coallescing failed because
> the second message had no credentials.
> 
> Ignoring credentials when we don't care in unix_stream_recvmsg fixes a
> long standing pessimization which would fail to coallesce messages when
> reading from a unix stream socket if the senders were different even if
> we did not care about their credentials.
> 
> I have tested this and verified that the in the LSB test case mentioned
> above that the messages do coallesce now, while the were failing to
> coallesce without this change.
> 
> Reported-by: Karel Srot <ksrot@redhat.com>
> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
