From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net 1/5] ibmvnic: harden interrupt handler
Date: Thu, 26 Jan 2017 12:57:02 -0600
Message-ID: <8fa5134a-25a7-165a-d035-cc86cd690885@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20170125.230413.830821835017116629.davem@davemloft.net>
 <0cea7654-6722-5e68-cd05-cc51bbf7a5ae@linux.vnet.ibm.com>
 <20170126.125624.243097121899163842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wvoigt@us.ibm.com, linuxppc-dev@lists.ozlabs.org,
 nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20170126.125624.243097121899163842.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On 01/26/2017 11:56 AM, David Miller wrote:
> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Date: Thu, 26 Jan 2017 10:44:22 -0600
>
>> On 01/25/2017 10:04 PM, David Miller wrote:
>>> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>>> Date: Wed, 25 Jan 2017 15:02:19 -0600
>>>
>>>> Move most interrupt handler processing into a tasklet, and
>>>> introduce a delay after re-enabling interrupts to fix timing
>>>> issues encountered in hardware testing.
>>>>
>>>> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>>> I don't think you have any idea what the real problem is.  This looks
>>> like a hack, at best.  Next patch you'll increase the delay to "20",
>>> right?  And if that doesn't work you'll try "40".
>>>
>>> Or if you do know the reason, you need to explain it in detail in this
>>> commit message so that we can properly evaluate this patch.
>> You're right, I should have given more explanation in the commit message about the bug encountered and our reasons for this sort of fix.  The issue is that there are some scenarios during the device init where multiple messages are sent by firmware in one interrupt request. 
>>
>> We have observed behavior where messages are delayed, resulting in the interrupt handler completing before the delayed messages can be processed, fouling up the device bring-up in the device probing and elsewhere.  The goal of the delay is to buy some time for the hypervisor to forward all the CRQ messages from the firmware.
> Then isn't there an event you can sleep and wait for, or a piece of state for
> you to poll and test for in a timeout based loop?
>
> This delay is a bad solution for the problem of waiting for A to happen
> before you do B.
>
Understood.  We will come up with a better fix.  Thanks for your attention.
