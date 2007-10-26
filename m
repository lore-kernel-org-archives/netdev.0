From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Bad TCP checksum error
Date: Fri, 26 Oct 2007 09:59:16 -0700
Message-ID: <47221CE4.70103@hp.com>
References: <1a41e0840710260041u4ebeb1e3h521e740a78f7e0bf@mail.gmail.com> <1a41e0840710260903w33516f62kc53e5eb56e424d69@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	davidsen@tmr.com
To: Gaurav Aggarwal <grv.aggarwal@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1a41e0840710260903w33516f62kc53e5eb56e424d69@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Checksum Offload on the NIC(s) can complicate things.  First, if you are tracing 
on the sender, the tracepoint is before the NIC has computed the full checksum. 
  IIRC only a partial checksum is passed-down to the NIC when CKO is in use.

So, making certain your trace is from the "wire" or the receiver rather than the 
sender would be a good thing, and trying again with CKO disabled on the 
interface(s) (via ethtool) might be something worth looking at.  Ultimately, 
doing the partial checksum modificiations in a CKO-friendly manner might be a 
good thing.

rick jones
