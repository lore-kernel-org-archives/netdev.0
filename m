From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] New Patch: Implementation for IPv6 MIB:ipv6AddressTable
Date: Thu, 9 Oct 2003 13:17:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310091317.35164.mashirle@us.ibm.com>
References: <OF4B7AD7E2.5CA239A1-ON87256DB9.0067C527@us.ibm.com> <20031008130016.559b8047.davem@redhat.com> <200310081706.09485.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru
In-Reply-To: <200310081706.09485.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, David,

There is possible loss of precision in the new patch for the timestamp. I have 
two solutions. 

Which one do you think is better.

This one is too much math.

ci.cstamp = (__u32)(TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) / HZ * 100
		  + TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
ci.tstamp = (__u32)(TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) / HZ * 100
		  + TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);

This one might overflow.

ci.cstamp = (__u32)(TIME_DELTA(ifa->cstamp, INITIAL_JIFFIES) *100 ) / HZ;
ci.tstamp = (__u32)(TIME_DELTA(ifa->tstamp, INITIAL_JIFFIES) * 100) / HZ;

Thanks
Shirley Ma
IBM Linux Technology Center
--------------------------------------------
