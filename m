From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [2/3] via-rhine: de-isolate PHY
Date: Sun, 08 Aug 2004 23:04:06 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <41169546.5000308@colorfullife.com>
References: <411684D5.8020302@colorfullife.com> <20040808200532.GA19170@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266292AbUHHVBh@vger.kernel.org>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040808200532.GA19170@k3.hellgate.ch>
List-Id: netdev.vger.kernel.org

Roger Luethi wrote:

>  
>
>>I know that PHYs go into isolate mode if the startup id is wired to 0, 
>>    
>>
>
>Wouldn't that be s/go/can go/ ?
>
>  
>
I don't have the MII standard, my knowledge is from the DP83840A specs:
The pin description contains a section about the phy ids:
During power up five pins are latched to determine the initial phy address.
Then the following sentence in bold: "An address selection of all zeros 
(00000) will result in a PHY isolation condition".

I've reread the DP specs and I now think that your current patch is 
sufficient:
The isolate state is independant from the phy address - a non-zero phy 
can be in isolate mode and the phy zero can be non-isolated. The phy id 
just sets the power-up value of the isolate bit: 0 means start isolated, 
non-zero means start non-isolated.

If this is really true then handling phy 0 is trivial:
First scan 1-31. If nothing found: try 0. If a phy is found: clear the 
isolate bit and then use phy 0.

--
    Manfred
