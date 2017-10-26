From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/2] bridge: netlink: make
 setlink/dellink notifications more accurate
Date: Thu, 26 Oct 2017 11:25:21 +0300
Message-ID: <3a9ba7b5-802c-7907-b91d-be076d448e78@cumulusnetworks.com>
References: <43f36fb0-8543-7e60-a80e-6da35d74b69a@cumulusnetworks.com>
	<1508968782-15530-1-git-send-email-nikolay@cumulusnetworks.com>
	<1508968782-15530-2-git-send-email-nikolay@cumulusnetworks.com>
	<20171026101702.6ff21fc1@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, mrv@mojatatu.com,
	dsa@cumulusnetworks.com, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20171026101702.6ff21fc1@shemminger-XPS-13-9360>
Content-Language: en-US
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

On 26/10/17 11:17, Stephen Hemminger wrote:
> On Thu, 26 Oct 2017 00:59:41 +0300
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> Before this patch we had cases that either sent notifications when there
>> were in fact no changes (e.g. non-existent vlan delete) or didn't send
>> notifications when there were changes (e.g. vlan add range with an error in
>> the middle, port flags change + vlan update error). This patch sends down
>> a boolean to the functions setlink/dellink use and if there is even a
>> single configuration change (port flag, vlan add/del, port state) then
>> we always send a notification. This is all done to keep backwards
>> compatibility with the opportunistic vlan delete, where one could
>> specify a vlan range that has missing vlans inside and still everything
>> in that range will be cleared, this is mostly used to clear the whole
>> vlan config with a single call, i.e. range 1-4094.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This looks correct.
> As a general note, generating a notice with no change should be ok for a correctly
> written application. But missing a notification would cause synchronization problems.
> 
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>
> 

Stephen, thank you for the review. Could you please send the ack to
v4 of this set ? Since it's already sent, I can't add it myself.

Thanks,
 Nik
