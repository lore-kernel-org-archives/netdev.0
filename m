From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic unless there was an error
Date: Fri, 12 Feb 2016 13:31:44 +0000
Message-ID: <871t8ivyv3.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87zivebxjr.fsf@doppelsaurus.mobileactivedefense.com>
	<56BCFDC8.6010406@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	hannes@stressinduktion.org, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Tim Gardner <tim.gardner@canonical.com>
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56BCFDC8.6010406@canonical.com> (Joseph Salisbury's message of
	"Thu, 11 Feb 2016 16:31:52 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joseph Salisbury <joseph.salisbury@canonical.com> writes:
> On 02/05/2016 05:30 PM, Rainer Weikusat wrote:
>> The present unix_stream_read_generic contains various code sequences of
>> the form
>>
>> err = -EDISASTER;
>> if (<test>)
>> 	goto out;

[...]

>> Change it such that err is only set if an error condition was detected.

[...]

> I tested your patch, Rainer.  I can confirm that it fixes the reported
> bug[0].

This is only a partial fix: The launchpad test case will no longer fail
with EOPNOTSUPP and it will actually receive the credentials because the
message they're attached to was available by the time of the
recvmsg. But if this isn't the case, ie, if the receiver has to wait for
a message, the continue in the do { } while (size) loop will cause the
loop to be terminated without copying the credential information as the
continue will cause the size (of the remaining 'receive area' which is
zero for this case) to be checked before any of the other loop code is
executed again.

I posted a test case for this and a patch addressing that elsewhere in
this thread.
