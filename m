From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net-next 2/2] pktgen: Specify the index of first thread
Date: Wed, 14 Jun 2017 14:10:37 +0300
Message-ID: <61690488-f20e-6768-e007-bd8b89cc0bf7@mellanox.com>
References: <1497366289-22255-1-git-send-email-tariqt@mellanox.com>
 <1497366289-22255-3-git-send-email-tariqt@mellanox.com>
 <20170614090922.541cf241@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0067.outbound.protection.outlook.com ([104.47.0.67]:1381
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751707AbdFNLKr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:10:47 -0400
In-Reply-To: <20170614090922.541cf241@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 14/06/2017 10:09 AM, Jesper Dangaard Brouer wrote:
> On Tue, 13 Jun 2017 18:04:49 +0300
> Tariq Toukan <tariqt@mellanox.com> wrote:
> 
>> Use "-f <num>", to specify the index of the first
>> sender thread.
>> In default first thread is #0.
>>
>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
>> ---
>>   samples/pktgen/README.rst                             |  1 +
>>   samples/pktgen/parameters.sh                          | 19 ++++++++++++++-----
>>   .../pktgen/pktgen_bench_xmit_mode_netif_receive.sh    |  4 ++--
>>   samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh   |  4 ++--
>>   samples/pktgen/pktgen_sample02_multiqueue.sh          |  4 ++--
>>   samples/pktgen/pktgen_sample03_burst_single_flow.sh   |  4 ++--
>>   samples/pktgen/pktgen_sample04_many_flows.sh          |  4 ++--
>>   samples/pktgen/pktgen_sample05_flow_per_thread.sh     |  4 ++--
>>   8 files changed, 27 insertions(+), 17 deletions(-)
>>
>> diff --git a/samples/pktgen/README.rst b/samples/pktgen/README.rst
>> index c018d67da1a1..527056bd27b7 100644
>> --- a/samples/pktgen/README.rst
>> +++ b/samples/pktgen/README.rst
>> @@ -21,6 +21,7 @@ across the sample scripts.  Usage example is printed on errors::
>>     -d : ($DEST_IP)   destination IP
>>     -m : ($DST_MAC)   destination MAC-addr
>>     -t : ($THREADS)   threads to start
>> +  -f : ($F_THREAD)  index of first thread
> 
> IMHO the help text should be:
>   "index of first thread (zero indexed CPU number)"
> 
Yeah sounds better. I'll change this.
> 
>>     -c : ($SKB_CLONE) SKB clones send before alloc new SKB
>>     -n : ($COUNT)     num messages to send per thread, 0 means indefinitely
>>     -b : ($BURST)     HW level bursting of SKBs
>> diff --git a/samples/pktgen/parameters.sh b/samples/pktgen/parameters.sh
>> index 036147594a20..d2dfc5cfa66b 100644
>> --- a/samples/pktgen/parameters.sh
>> +++ b/samples/pktgen/parameters.sh
>> @@ -10,6 +10,7 @@ function usage() {
>>       echo "  -d : (\$DEST_IP)   destination IP"
>>       echo "  -m : (\$DST_MAC)   destination MAC-addr"
>>       echo "  -t : (\$THREADS)   threads to start"
>> +    echo "  -f : (\$F_THREAD)  index of first thread"
> 
> Same here:
>   IMHO the help text should be:
>   "index of first thread (zero indexed CPU number)"
> 
Yes.
> 
>>       echo "  -c : (\$SKB_CLONE) SKB clones send before alloc new SKB"
>>       echo "  -n : (\$COUNT)     num messages to send per thread, 0 means indefinitely"
>>       echo "  -b : (\$BURST)     HW level bursting of SKBs"
>> @@ -21,7 +22,7 @@ function usage() {
>>   
>>   ##  --- Parse command line arguments / parameters ---
>>   ## echo "Commandline options:"
>> -while getopts "s:i:d:m:t:c:n:b:vxh6" option; do
>> +while getopts "s:i:d:m:f:t:c:n:b:vxh6" option; do
>>       case $option in
>>           i) # interface
>>             export DEV=$OPTARG
>> @@ -39,11 +40,13 @@ while getopts "s:i:d:m:t:c:n:b:vxh6" option; do
>>             export DST_MAC=$OPTARG
>>   	  info "Destination MAC set to: DST_MAC=$DST_MAC"
>>             ;;
>> +        f)
>> +	  export F_THREAD=$OPTARG
>> +	  info "Index of first thread: $F_THREAD"
>> +          ;;
>>           t)
>>   	  export THREADS=$OPTARG
>> -          export CPU_THREADS=$OPTARG
>> -	  let "CPU_THREADS -= 1"
>> -	  info "Number of threads to start: $THREADS (0 to $CPU_THREADS)"
>> +	  info "Number of threads to start: $THREADS"
>>             ;;
>>           c)
>>   	  export CLONE_SKB=$OPTARG
>> @@ -82,12 +85,18 @@ if [ -z "$PKT_SIZE" ]; then
>>       info "Default packet size set to: set to: $PKT_SIZE bytes"
>>   fi
>>   
>> +if [ -z "$F_THREAD" ]; then
>> +    # Zero CPU threads means one thread, because CPU numbers are zero indexed
> 
> Wrong comment, use:
> # First thread (F_THREAD) reference the zero indexes CPU number
> 
I'll fix.
>> +    export F_THREAD=0
>> +fi
>> +
>>   if [ -z "$THREADS" ]; then
>>       # Zero CPU threads means one thread, because CPU numbers are zero indexed
>> -    export CPU_THREADS=0
> 
> Also remove comment, it is talking about CPU_THREADS
> 
I'll fix.
>>       export THREADS=1
>>   fi
>>   
>> +export L_THREAD="$THREADS + $F_THREAD - 1"
>> +
> 
> This is sort of bad-shell coding.  This will first get expanded at the
> usage point.  The way you use it, it will work, because of the for loop
> uses an expansion like "((xxx))".
> 
> If you echo the $L_THREAD variable you will see: "1 + 0 - 1"
> 
> IMHO the right thing is to use:
> 
>    export L_THREAD=$(( THREADS + F_THREAD - 1 ))
> 
> (I tested this also works for dash + ksh + zsh)
> 
Thanks, I'll use the suggested command.
> 
>> diff --git a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
>> index d2694a12de61..e5bfe759a0fb 100755
>> --- a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
>> +++ b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
>> @@ -48,7 +48,7 @@ DELAY="0"        # Zero means max speed
>>   pg_ctrl "reset"
>>   
>>   # Threads are specified with parameter -t value in $THREADS
>> -for ((thread = 0; thread < $THREADS; thread++)); do
>> +for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
>>       # The device name is extended with @name, using thread number to
>>       # make then unique, but any name will do.
>>       dev=${DEV}@${thread}
> 
> The expansion/use of $L_THREAD only works because "for-loop" expanded
> it by using ""(("" arithmetic evaluation.
> 
After changing the one above, this one should still be OK, right?

Thanks for you comments!

Regards,
Tariq
