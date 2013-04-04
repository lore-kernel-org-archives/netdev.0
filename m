From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] Revert "af_unix: dont send SCM_CREDENTIAL when dest socket is NULL"
Date: Thu, 04 Apr 2013 03:22:07 -0700
Message-ID: <87r4iqegts.fsf@xmission.com>
References: <20130402221104.163133110@linuxfoundation.org>
	<20130402221116.307254752@linuxfoundation.org>
	<87vc833kpf.fsf@turtle.gmx.de> <87k3ojnosa.fsf@xmission.com>
	<1365034777.13853.46.camel@edumazet-glaptop>
	<1365035424.13853.48.camel@edumazet-glaptop>
	<878v4zjei0.fsf@xmission.com> <87li8zhwkw.fsf_-_@xmission.com>
	<515D30F6.9010004@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Sven Joachim <svenjoac@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Karel Srot <ksrot@redhat.com>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <515D30F6.9010004@huawei.com> (dingtianhong@huawei.com's message
	of "Thu, 4 Apr 2013 15:51:18 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dingtianhong <dingtianhong@huawei.com> writes:

> On 2013/4/4 10:13, Eric W. Biederman wrote:
>> 
>> This reverts commit 14134f6584212d585b310ce95428014b653dfaf6.
>> 
>> The problem that the above patch was meant to address is that af_unix
>> messages are not being coallesced because we are sending unnecesarry
>> credentials.  Not sending credentials in maybe_add_creds totally
>> breaks unconnected unix domain sockets that wish to send credentails
>> to other sockets.
>> 
>
> thanks for check the question and make a fix solution, but I still doubt that if unconnected unix
> domain socket wish to send credentails to oher sockets, why dont set
> SOCK_PASSCRED on sock->flags, I think the user need to decide the param
> and shouldnt send creds by default way.

The big issue is the semantics are the receiver sets SOCK_PASSCRED when
they want to receive credentials.  When transmitting packets from
unconnected or unaccepted sockets we don't know if the receiver has set
SOCK_PASSCRED so when in doubt transmit. Historically we always
tranmitted credentials.

Furthermore we have a real regression in udev that breaks systems, so
this patch must be reverted.

Eric
