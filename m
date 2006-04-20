From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [RFC] Netlink and user-space buffer pointers
Date: Thu, 20 Apr 2006 12:52:10 -0500
Message-ID: <4447CA4A.4000707@cs.wisc.edu>
References: <1145306661.4151.0.camel@localhost.localdomain> <20060418160121.GA2707@us.ibm.com> <444633B5.5030208@emulex.com> <4446AC80.6040604@cs.wisc.edu> <44479BA8.1000405@emulex.com> <4447C8C2.30909@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: James.Smart@Emulex.Com
In-Reply-To: <4447C8C2.30909@cs.wisc.edu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Christie wrote:
> James Smart wrote:
>> Mike Christie wrote:
>>> For the tasks you want to do for the fc class is performance critical?
>> No, it should not be.
>>
>>> If not, you could do what the iscsi class (for the netdev people this is
>>> drivers/scsi/scsi_transport_iscsi.c) does and just suffer a couple
>>> copies. For iscsi we do this in userspace to send down a login pdu:
>>>
>>>     /*
>>>      * xmitbuf is a buffer that is large enough for the iscsi_event,
>>>      * iscsi pdu (hdr_size) and iscsi pdu data (data_size)
>>>      */
>> Well, the real difference is that the payload of the "message" is actually
>> the payload of the SCSI command or ELS/CT Request. Thus, the payload may
> 
> I am not sure I follow. For iscsi, everything after the iscsi_event
> struct can be the iscsi request that is to be transmitted. The payload
> will not normally be Mbytes but it is not a couple if bytes.
> 
>> range in size from a few hundred bytes to several kbytes (> 1 page) to
>> Mbyte's in size. Rather than buffer all of this, and push it over the
>> socket,
>> thus the extra copies - it would best to have the LLDD simply DMA the
>> payload like on a typical SCSI command.  Additionally, there will be
>> response data that can be several kbytes in length.
>>
> 
> Once you have got the buffer to the class, the class can create a
> scatterlist to DMA from for the LLD. I thought. iscsi does not do this
> just because it is software right now. For qla4xxx we do not need

That should be, we do need.
