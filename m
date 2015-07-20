From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: mdb: add vlan support for
	user entries
Date: Tue, 21 Jul 2015 00:53:09 +0200
Message-ID: <55AD7BD5.4090505@cumulusnetworks.com>
References: <1436540528-42334-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150720152817.4c2f5c73@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150720152817.4c2f5c73@urahara>
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

On 07/21/2015 12:28 AM, Stephen Hemminger wrote:
> On Fri, 10 Jul 2015 08:02:08 -0700
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
>> index eaaea6208b42..3635b7797508 100644
>> --- a/include/uapi/linux/if_bridge.h
>> +++ b/include/uapi/linux/if_bridge.h
>> @@ -182,6 +182,7 @@ struct br_mdb_entry {
>>  #define MDB_TEMPORARY 0
>>  #define MDB_PERMANENT 1
>>  	__u8 state;
>> +	__u16 vid;
>>  	struct {
>>  		union {
>>  			__be32	ip4;
> 
> You added a new field into an unused hole in a data
> structure shared as part of API with user space.
> 
> This seems like it might break when newer iproute
> is run on older kernels. The vid would always be 0
> on show and ignored when adding entries.
> 

I thought it'd be fine because the vid was 0 anyway and 
when it's 0 it's not shown i.e. no vid so the show command
will have the same output. And when set - it'll be ignored
which is again as the behaviour before when it couldn't be
specified.

Here's the new iproute2 on an older kernel:
# ./bridge/bridge mdb add dev virbr0 port vnet1 grp 239.0.0.1 permanent vid 200
# ./bridge/bridge mdb
dev virbr0 port vnet1 grp 239.0.0.1 permanent
