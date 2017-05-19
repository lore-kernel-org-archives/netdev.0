From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net] bridge: fix hello and hold timers
	starting/stopping
Date: Fri, 19 May 2017 19:06:21 +0200
Message-ID: <CA+Nub0bpM1ez-SBdqz3zzFDZYVRVNprEop=pLwhveZ3_wxU=Qg@mail.gmail.com>
References: <20170519162543.31670-1-cera@cera.cz>
	<4fb3ce7a-b3d8-b62e-2263-eb3fab2ff2fe@cumulusnetworks.com>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Xin Long <lucien.xin@gmail.com>, network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, David Miller <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <4fb3ce7a-b3d8-b62e-2263-eb3fab2ff2fe@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

2017-05-19 18:55 GMT+02:00 Nikolay Aleksandrov <nikolay@cumulusnetworks.com>:
> On 5/19/17 7:25 PM, Ivan Vecera wrote:
>>
>> Current bridge code incorrectly handles starting/stopping of hello and
>> hold timers during STP enable/disable.
>>
>> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
>>     transition. This is not correct as the timers are stopped in NO_STP
>>     case.
>
>
> This really is a noop, but ok.

Yes, stopping of stopped timers are safe but confusing.

>> 2. Timers are started in br_stp_stop() during USER_STP->NO_STP transition.
>>     This is not also correct as the timers should be stopped in NO_STP
>>     state.
>
>
> Indeed, but the actual end result is almost as them being stopped because
> in the timers there are specific checks if the STP == KERNEL_STP (see
> br_transmit_config()) and the hold_timers will simply expire and not rearm
> in any other mode. The only real problem is the hello_timer which continues
> to rearm itself, but with Xin's earlier patch that is taken care of too.

Yes, this is clean-up as well. The starting of timers are more
confusing than dangerous
but from a reader's point of view the starting of timers is non-sense
when STP is
going to be disabled.

>>
>> 3. Timers are NOT stopped in br_stp_stop() during KERNEL_STP->NO_STP
>>     transition. They should be stopped as they are running in KERNEL_STP
>>     state and should not run in NO_STP case.
>
>
> Same comment as for point 2.
This can be removed... and leave hello_timer handler to stop itself.

>> The patch is a follow-up for "bridge: start hello_timer when enabling
>> KERNEL_STP in br_stp_start" patch from Xin Long.
>>
>
> I'd say this is more of a cleanup/improvement after Xin's patch and thus
> would
> suggest targeting net-next. The only real issue is fixed by his patch.
Agree... will send resend against net-next.

Thanks for comments,
Ivan
