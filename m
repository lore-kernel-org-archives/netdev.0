From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: bridge: add helper to call /sbin/bridge-stp
Date: Fri, 09 Sep 2016 09:09:32 -0400
Message-ID: <87lgz143ub.fsf@ketchup.mtl.sfl>
References: <20160908165043.31042-1-vivien.didelot@savoirfairelinux.com> <20160908175857.35565496@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160908175857.35565496@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Thu,  8 Sep 2016 12:50:43 -0400
> Vivien Didelot <vivien.didelot@savoirfairelinux.com> wrote:
>
>> If /sbin/bridge-stp is available on the system, bridge tries to execute
>> it instead of the kernel implementation when starting/stopping STP.
>> 
>> If anything goes wrong with /sbin/bridge-stp, bridge silently falls back
>> to kernel STP, making hard to debug userspace STP.
>> 
>> This patch adds a br_stp_call_user helper to start/stop userspace STP
>> and debug errors from the program: abnormal exit status is stored in the
>> lower byte and normal exit status is stored in higher byte.
>> 
>> Below is a simple example on a kernel with dynamic debug enabled:
>> 
>>     # ln -s /bin/false /sbin/bridge-stp
>>     # brctl stp br0 on
>>     br0: failed to start userspace STP (256)
>>     # dmesg
>>     br0: /sbin/bridge-stp exited with code 1
>>     br0: failed to start userspace STP (256)
>>     br0: using kernel STP
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> I understand that debugging STP is hard. But this solution looks like it
> would break existing userspace because you changed an API.

My commit message might not be clear enough, sorry about that.

This patch does not bring any functional changes.

It factorizes the two calls to call_usermodehelper in a br_stp_call_user
function, which prints debug messages for userspace errors if the
program gets killed (e.g. ABRT) or exited with non-zero status.

br_err is used if userspace STP start/stop fails, which gives direct
diagnostic to the user.

I can provide more example scenarios if you wish to.

Thanks,

        Vivien
