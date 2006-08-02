From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: Re: [PATCH 2.6.16.19 0/2] LARTC: trace control for netem
Date: Wed, 02 Aug 2006 21:02:55 +0200
Message-ID: <44D0F6DF.9060408@tik.ee.ethz.ch>
References: <44D0DF17.6060809@tik.ee.ethz.ch> <20060802111921.31906ea1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@VGER.KERNEL.ORG, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060802111921.31906ea1@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanx for your feedback! We will try to fix this.
Rainer

Stephen Hemminger wrote:
> On Wed, 02 Aug 2006 19:21:27 +0200
> Rainer Baumann <baumann@tik.ee.ethz.ch> wrote:
>
>   
>> Hi,
>>
>> We developed an extension to the network emulator netem, that provides
>> emulation of long term network properties such as long-range dependence
>> and self-similarity of cross-traffic. It is not possible to emulate
>> these properties with the  statistical tables for the packet delay
>> values used by the original netem.
>>
>> We read the values for the packet delay, drop, loss and corruption from
>> a pre-generated trace file. This trace file is obtained by monitoring
>> network traffic and writing all actions to a trace file. During the
>> emulation the packets get processed according the values in such a trace
>> file. Detailed information are available on our
>> Webseitehttp://tcn.hypert.net
>>
>> A new option (trace) has been added to the netem command. If the trace
>> option is used, the values for packet delay etc. are read from a trace
>> file, afterwards the packets are processed by the normal netem functions.
>> The packet action values are readout from the trace file in user space
>> and sent to kernel space via procfs.
>>
>> The evaluation results show similar behavior for our enhancement and the
>> original netem with respect to packet delay precision and packet loss at
>> high load (e.g. 80'000 packets per second).
>> It is possible to add, change or delete multiple netem qdiscs on-the-fly
>> (original netem qdiscs and trace qdiscs mixed).
>>
>> We are looking forward for any comments, feedback and suggestions!
>>
>> Thanks,
>> Rainer
>>     
>
> I like the idea and want to get it incorporated.
>
> Major things that need fixing:
> * Don't extend size of tc_netem_qopt instead use a new netlink
>   payload.
>     + add type to TCA_NETEM_ enum
>     + new structure containing the payload
>   This allows for binary compatiablity.
>
> * Don't use proc for a interface to netem features. Use netlink.
>   Either add a new command (or option) to the iproute2 commands
>   to handle flow table, or add a new payload.
>
>
> Minor stuff:
> * the bzero macro in netem is a BSDism, just use memset
> * bad indentation and style issues.
> * minor whitespace damage in several places in patch
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   



